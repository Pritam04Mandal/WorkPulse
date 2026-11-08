import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/setting_keys.dart';
import '../../../core/domain/enums.dart';
import '../domain/app_classifier.dart';
import '../domain/sessionizer.dart';
import '../domain/usage_models.dart';
import 'usage_gateway.dart';

/// Android keeps roughly this much of its usage log.
const _maxCatchUp = Duration(days: 7);

const _alwaysIgnored = {'com.workpulse.app', 'com.android.systemui'};

class TrackingRepository {
  TrackingRepository({
    required AppDatabase database,
    required this._gateway,
    this._clock = DateTime.now,
  }) : _db = database;

  final AppDatabase _db;
  final UsageAccessGateway _gateway;
  final DateTime Function() _clock;

  Future<bool> isPrivateSession() async =>
      await _db.readSetting(privateSessionSettingKey) == 'true';

  /// Turning it on records up to now first. Turning it off moves the import
  /// floor, so nothing from the private stretch is ever read back.
  Future<void> setPrivateSession(bool on) async {
    if (on) {
      await sync();
      await _db.writeSetting(privateSessionSettingKey, 'true');
    } else {
      await _db.writeSetting(
        importFloorSettingKey,
        '${_clock().millisecondsSinceEpoch}',
      );
      await _db.deleteSetting(privateSessionSettingKey);
    }
  }

  /// Imports new sessions from Android's log. Returns whether Usage Access
  /// is granted.
  Future<bool> sync() async {
    final source = await _ensureSource();
    if (!await _gateway.isGranted()) {
      await _updateSource(
        source.id,
        const DataSourcesCompanion(status: Value(SourceStatus.disconnected)),
      );
      return false;
    }
    if (await isPrivateSession()) return true;

    final now = _clock();
    final nowMs = now.millisecondsSinceEpoch;
    final startMs = await _windowStart(source, now);
    final raw = await _gateway.queryEvents(startMs, nowMs);
    final result = buildSessions(raw, cursorMs: startMs, nowMs: nowMs);

    final ignored = await _ignoredPackages();
    final deleted = await _tombstones(source.id);
    final sessions = result.sessions
        .where((s) => !ignored.contains(s.package))
        .expand(splitAtMidnight)
        .where((s) => !deleted.contains(s.externalId))
        .toList();
    final labels = sessions.isEmpty
        ? const <String, String>{}
        : await _gateway.appLabels(
            sessions.map((s) => s.package).toSet().toList(),
          );

    await _db.transaction(() async {
      await _db.batch(
        (batch) => batch.insertAll(_db.activityEvents, [
          for (final session in sessions)
            ActivityEventsCompanion.insert(
              sourceId: source.id,
              externalId: Value(session.externalId),
              kind: ActivityKind.appUsage,
              category: categoryForPackage(session.package),
              title: labels[session.package] ?? session.package,
              application: Value(session.package),
              startedAt: DateTime.fromMillisecondsSinceEpoch(session.startMs),
              endedAt: Value(
                DateTime.fromMillisecondsSinceEpoch(session.endMs),
              ),
              mergedEventCount: Value(session.mergedEvents),
            ),
        ], mode: InsertMode.insertOrIgnore),
      );
      await _updateSource(
        source.id,
        DataSourcesCompanion(
          status: const Value(SourceStatus.connected),
          syncCursor: Value('${result.nextCursorMs}'),
          lastSyncedAt: Value(now),
        ),
      );
    });
    return true;
  }

  Stream<List<TrackedActivity>> watchDay(DateTime day) {
    final start = startOfDay(day);
    final end = DateTime(start.year, start.month, start.day + 1);
    final query = _db.select(_db.activityEvents)
      ..where(
        (t) =>
            t.startedAt.isBiggerOrEqualValue(start) &
            t.startedAt.isSmallerThanValue(end),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.startedAt)]);
    return query.watch().map((rows) => rows.map(_toActivity).toList());
  }

  Stream<TrackedActivity?> watchActivity(String id) =>
      (_db.select(_db.activityEvents)..where((t) => t.id.equals(id)))
          .watchSingleOrNull()
          .map((row) => row == null ? null : _toActivity(row));

  /// Deletes an event and remembers it, so a later sync won't re-import it.
  Future<void> deleteActivity(String id) => _db.transaction(() async {
    final row = await (_db.select(
      _db.activityEvents,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    if (row.externalId != null) {
      await _db
          .into(_db.eventTombstones)
          .insertOnConflictUpdate(
            EventTombstonesCompanion.insert(
              sourceId: row.sourceId,
              externalId: row.externalId!,
              deletedAt: _clock(),
            ),
          );
    }
    await (_db.delete(_db.activityEvents)..where((t) => t.id.equals(id))).go();
  });

  Future<void> setActivityPrivate(String id, bool isPrivate) =>
      (_db.update(_db.activityEvents)..where((t) => t.id.equals(id))).write(
        ActivityEventsCompanion(isPrivate: Value(isPrivate)),
      );

  Future<void> correctTimes(String id, DateTime start, DateTime end) =>
      (_db.update(_db.activityEvents)..where((t) => t.id.equals(id))).write(
        ActivityEventsCompanion(
          startedAt: Value(start),
          endedAt: Value(end),
          isCorrected: const Value(true),
        ),
      );

  Future<List<InstalledApp>> installedApps() => _gateway.launchableApps();

  Stream<Set<String>> watchExcludedApps() =>
      (_db.select(_db.exclusions)
            ..where((t) => t.kind.equalsValue(ExclusionKind.app)))
          .watch()
          .map((rows) => rows.map((r) => r.value).toSet());

  /// Excluding an app also deletes everything recorded from it.
  Future<void> setAppExcluded(InstalledApp app, {required bool excluded}) =>
      _db.transaction(() async {
        if (!excluded) {
          await (_db.delete(_db.exclusions)..where(
                (t) =>
                    t.kind.equalsValue(ExclusionKind.app) &
                    t.value.equals(app.package),
              ))
              .go();
          return;
        }
        await _db
            .into(_db.exclusions)
            .insert(
              ExclusionsCompanion.insert(
                kind: ExclusionKind.app,
                value: app.package,
                label: Value(app.label),
                createdAt: _clock(),
              ),
              mode: InsertMode.insertOrIgnore,
            );
        await (_db.delete(
          _db.activityEvents,
        )..where((t) => t.application.equals(app.package))).go();
      });

  Future<DataSource> _ensureSource() async {
    final existing =
        await (_db.select(_db.dataSources)
              ..where((t) => t.kind.equalsValue(SourceKind.androidUsage))
              ..limit(1))
            .getSingleOrNull();
    return existing ??
        _db
            .into(_db.dataSources)
            .insertReturning(
              DataSourcesCompanion.insert(
                kind: SourceKind.androidUsage,
                status: SourceStatus.connected,
                connectedAt: _clock(),
              ),
            );
  }

  Future<void> _updateSource(String id, DataSourcesCompanion values) =>
      (_db.update(
        _db.dataSources,
      )..where((t) => t.id.equals(id))).write(values);

  /// The first sync imports today only; later ones resume from the cursor.
  Future<int> _windowStart(DataSource source, DateTime now) async {
    final oldest = now.subtract(_maxCatchUp).millisecondsSinceEpoch;
    final cursor =
        int.tryParse(source.syncCursor ?? '') ??
        startOfDay(now).millisecondsSinceEpoch;
    final floor =
        int.tryParse(await _db.readSetting(importFloorSettingKey) ?? '') ?? 0;
    return [oldest, cursor, floor].reduce((a, b) => a > b ? a : b);
  }

  Future<Set<String>> _ignoredPackages() async {
    final excluded = await (_db.select(
      _db.exclusions,
    )..where((t) => t.kind.equalsValue(ExclusionKind.app))).get();
    return {
      ..._alwaysIgnored,
      ...await _gateway.homePackages(),
      ...excluded.map((e) => e.value),
    };
  }

  Future<Set<String>> _tombstones(String sourceId) async {
    final rows = await (_db.select(
      _db.eventTombstones,
    )..where((t) => t.sourceId.equals(sourceId))).get();
    return rows.map((r) => r.externalId).toSet();
  }

  TrackedActivity _toActivity(ActivityEvent row) => TrackedActivity(
    id: row.id,
    kind: row.kind,
    category: row.category,
    title: row.title,
    start: row.startedAt,
    end: row.endedAt,
    application: row.application,
    projectId: row.projectId,
    mergedEvents: row.mergedEventCount,
    isPrivate: row.isPrivate,
    isCorrected: row.isCorrected,
  );
}
