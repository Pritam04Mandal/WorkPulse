import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/setting_keys.dart';
import '../../../core/domain/enums.dart';
import '../domain/github_models.dart';
import 'github_api.dart';
import 'github_token_store.dart';

const _firstSyncWindow = Duration(days: 30);

/// Re-reads a little history, because GitHub's search index lags behind.
const _overlap = Duration(days: 1);

class GitHubRepository {
  GitHubRepository({
    required AppDatabase database,
    required this._client,
    required this._tokens,
    this._clock = DateTime.now,
  }) : _db = database;

  final AppDatabase _db;
  final GitHubClient _client;
  final GitHubTokenStore _tokens;
  final DateTime Function() _clock;

  Stream<GitHubStatus?> watchStatus() => _db
      .customSelect(
        '''
      SELECT s.*,
        (SELECT COUNT(*) FROM activity_events e WHERE e.source_id = s.id)
          AS event_count,
        (SELECT COUNT(*) FROM tracked_repositories r
          WHERE r.source_id = s.id AND r.ignored = 0) AS tracked_count,
        (SELECT COUNT(*) FROM tracked_repositories r
          WHERE r.source_id = s.id AND r.ignored = 1) AS ignored_count
      FROM data_sources s WHERE s.kind = ? LIMIT 1
      ''',
        variables: [Variable.withString(SourceKind.github.name)],
        readsFrom: {
          _db.dataSources,
          _db.activityEvents,
          _db.trackedRepositories,
        },
      )
      .watchSingleOrNull()
      .map((row) {
        if (row == null) return null;
        final status = row.read<String>('status');
        return GitHubStatus(
          login: row.read<String?>('account_label') ?? '',
          connected: status != SourceStatus.disconnected.name,
          needsReconnect: status == SourceStatus.error.name,
          eventCount: row.read<int>('event_count'),
          trackedRepositories: row.read<int>('tracked_count'),
          ignoredRepositories: row.read<int>('ignored_count'),
          scopes: row.read<String?>('granted_scopes'),
          lastSyncedAt: row.read<DateTime?>('last_synced_at'),
        );
      });

  Stream<List<TrackedRepository>> watchRepositories() {
    final query =
        _db.select(_db.trackedRepositories).join([
            innerJoin(
              _db.dataSources,
              _db.dataSources.id.equalsExp(_db.trackedRepositories.sourceId),
            ),
          ])
          ..where(_db.dataSources.kind.equalsValue(SourceKind.github))
          ..orderBy([OrderingTerm.asc(_db.trackedRepositories.fullName)]);
    return query.watch().map(
      (rows) => rows.map((r) => r.readTable(_db.trackedRepositories)).toList(),
    );
  }

  /// Stores a newly approved token and the account's repositories. The first
  /// [sync] is left to the caller, so repositories can be ignored before it.
  Future<void> completeConnection(String token, String scopes) async {
    final login = await _client.fetchLogin(token);
    final repositories = await _client.fetchRepositories(token);
    await _tokens.save(token);
    await _db.transaction(() async {
      final existing = await _source();
      final values = DataSourcesCompanion(
        status: const Value(SourceStatus.connected),
        accountLabel: Value(login),
        grantedScopes: Value(scopes),
      );
      final id = existing == null
          ? (await _db
                    .into(_db.dataSources)
                    .insertReturning(
                      values.copyWith(
                        kind: const Value(SourceKind.github),
                        connectedAt: Value(_clock()),
                      ),
                    ))
                .id
          : existing.id;
      if (existing != null) await _updateSource(id, values);
      await _addRepositories(id, repositories);
    });
  }

  /// Imports anything new. Does nothing while disconnected or private.
  Future<void> sync() async {
    final source = await _source();
    if (source == null || source.status == SourceStatus.disconnected) return;
    if (await _db.readSetting(privateSessionSettingKey) == 'true') return;
    final token = await _tokens.read();
    if (token == null) return;

    final now = _clock();
    final since = await _windowStart(source, now);
    final List<GitHubActivity> activity;
    try {
      activity = await _client.fetchActivity(
        token,
        login: source.accountLabel ?? '',
        since: since,
        until: now,
      );
    } on GitHubFailure catch (failure) {
      if (failure.kind == GitHubFailureKind.revoked) {
        await _updateSource(
          source.id,
          const DataSourcesCompanion(status: Value(SourceStatus.error)),
        );
      }
      rethrow;
    }

    final known = await _repositoriesFor(source.id);
    final ignored = {
      for (final repo in known)
        if (repo.ignored) repo.fullName,
    };
    final deleted = await _tombstones(source.id);
    final fresh = activity
        .where((a) => !ignored.contains(a.repository))
        .where((a) => !deleted.contains(a.externalId))
        .where((a) => !a.occurredAt.isBefore(since))
        .toList();

    await _db.transaction(() async {
      await _addRepositories(source.id, fresh.map((a) => a.repository));
      await _db.batch(
        (batch) => batch.insertAll(_db.activityEvents, [
          for (final item in fresh)
            ActivityEventsCompanion.insert(
              sourceId: source.id,
              externalId: Value(item.externalId),
              kind: item.kind,
              category: ActivityCategory.coding,
              title: item.title,
              domain: Value(item.repository),
              startedAt: item.occurredAt,
            ),
        ], mode: InsertMode.insertOrIgnore),
      );
      await _updateSource(
        source.id,
        DataSourcesCompanion(
          status: const Value(SourceStatus.connected),
          syncCursor: Value('${now.millisecondsSinceEpoch}'),
          lastSyncedAt: Value(now),
        ),
      );
    });
  }

  /// Ignoring a repository also deletes what was recorded from it.
  Future<void> setRepositoryIgnored(
    TrackedRepository repository, {
    required bool ignored,
  }) => _db.transaction(() async {
    await (_db.update(_db.trackedRepositories)
          ..where((t) => t.id.equals(repository.id)))
        .write(TrackedRepositoriesCompanion(ignored: Value(ignored)));
    if (!ignored) return;
    await (_db.delete(_db.activityEvents)..where(
          (t) =>
              t.sourceId.equals(repository.sourceId) &
              t.domain.equals(repository.fullName),
        ))
        .go();
  });

  /// Removes the token. With [keepEvents] false, its history goes too.
  Future<void> disconnect({required bool keepEvents}) async {
    await _tokens.clear();
    final source = await _source();
    if (source == null) return;
    if (keepEvents) {
      await _updateSource(
        source.id,
        const DataSourcesCompanion(status: Value(SourceStatus.disconnected)),
      );
    } else {
      await (_db.delete(
        _db.dataSources,
      )..where((t) => t.id.equals(source.id))).go();
    }
  }

  Future<RateBudget?> rateBudget() async {
    final token = await _tokens.read();
    return token == null ? null : _client.fetchRateBudget(token);
  }

  Future<DateTime?> lastSyncedAt() async => (await _source())?.lastSyncedAt;

  Future<DataSource?> _source() =>
      (_db.select(_db.dataSources)
            ..where((t) => t.kind.equalsValue(SourceKind.github))
            ..limit(1))
          .getSingleOrNull();

  Future<void> _updateSource(String id, DataSourcesCompanion values) =>
      (_db.update(
        _db.dataSources,
      )..where((t) => t.id.equals(id))).write(values);

  Future<void> _addRepositories(String sourceId, Iterable<String> names) =>
      _db.batch(
        (batch) => batch.insertAll(_db.trackedRepositories, [
          for (final name in names.toSet())
            TrackedRepositoriesCompanion.insert(
              sourceId: sourceId,
              fullName: name,
            ),
        ], mode: InsertMode.insertOrIgnore),
      );

  Future<List<TrackedRepository>> _repositoriesFor(String sourceId) =>
      (_db.select(
        _db.trackedRepositories,
      )..where((t) => t.sourceId.equals(sourceId))).get();

  Future<Set<String>> _tombstones(String sourceId) async {
    final rows = await (_db.select(
      _db.eventTombstones,
    )..where((t) => t.sourceId.equals(sourceId))).get();
    return rows.map((r) => r.externalId).toSet();
  }

  /// The first sync reaches back 30 days. Later ones never go behind the
  /// import floor, which is how a private session stays private.
  Future<DateTime> _windowStart(DataSource source, DateTime now) async {
    final cursor = int.tryParse(source.syncCursor ?? '');
    if (cursor == null) return now.subtract(_firstSyncWindow);
    final floor =
        int.tryParse(await _db.readSetting(importFloorSettingKey) ?? '') ?? 0;
    final resumeFrom = DateTime.fromMillisecondsSinceEpoch(cursor)
        .subtract(_overlap);
    final floorTime = DateTime.fromMillisecondsSinceEpoch(floor);
    return resumeFrom.isAfter(floorTime) ? resumeFrom : floorTime;
  }
}
