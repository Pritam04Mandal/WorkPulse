import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workpulse/core/database/app_database.dart';
import 'package:workpulse/core/database/setting_keys.dart';
import 'package:workpulse/core/domain/enums.dart';
import 'package:workpulse/features/github/data/github_api.dart';
import 'package:workpulse/features/github/data/github_repository.dart';
import 'package:workpulse/features/github/data/github_token_store.dart';
import 'package:workpulse/features/github/domain/github_models.dart';
import 'package:workpulse/features/tracking/domain/usage_models.dart';

class FakeClient implements GitHubClient {
  List<GitHubActivity> activity = [];
  List<String> repositories = ['me/app', 'me/dotfiles'];
  DateTime? lastSince;
  GitHubFailure? failure;

  @override
  Future<List<GitHubActivity>> fetchActivity(
    String token, {
    required String login,
    required DateTime since,
    required DateTime until,
  }) async {
    if (failure != null) throw failure!;
    lastSince = since;
    return activity;
  }

  @override
  Future<String> fetchLogin(String token) async => 'me';

  PushedRepositories? pushed;
  String? seenEtag;
  final polledRepositories = <String>[];
  Map<String, List<GitHubActivity>> recent = {};

  @override
  Future<PushedRepositories?> fetchPushedRepositories(
    String token, {
    String? etag,
  }) async {
    if (failure != null) throw failure!;
    seenEtag = etag;
    return pushed;
  }

  @override
  Future<List<GitHubActivity>> fetchRecentCommits(
    String token, {
    required String repository,
    required String login,
    required DateTime since,
  }) async {
    polledRepositories.add(repository);
    return recent[repository] ?? const [];
  }

  @override
  Future<RateBudget> fetchRateBudget(String token) async =>
      const RateBudget(4870, 5000);

  @override
  Future<List<String>> fetchRepositories(String token) async => repositories;

  @override
  Future<PollResult> pollForToken(String deviceCode) async =>
      const PollPending();

  @override
  Future<DeviceCode> requestDeviceCode() => throw UnimplementedError();
}

class MemoryTokens implements GitHubTokenStore {
  String? token;

  @override
  Future<void> clear() async => token = null;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> save(String value) async => token = value;
}

GitHubActivity commit(String sha, String repo, DateTime at) => GitHubActivity(
  externalId: 'commit:$sha',
  kind: ActivityKind.commit,
  title: 'Commit · $sha',
  repository: repo,
  occurredAt: at,
);

void main() {
  late AppDatabase db;
  late FakeClient client;
  late MemoryTokens tokens;
  late GitHubRepository repo;
  late DateTime now;

  setUp(() {
    now = DateTime(2026, 11, 9, 12);
    db = AppDatabase(NativeDatabase.memory());
    client = FakeClient();
    tokens = MemoryTokens();
    repo = GitHubRepository(
      database: db,
      client: client,
      tokens: tokens,
      clock: () => now,
    );
  });
  tearDown(() => db.close());

  Future<List<ActivityEvent>> events() => db.select(db.activityEvents).get();

  test('connecting stores the token outside the database', () async {
    await repo.completeConnection('secret-token', 'repo');

    expect(tokens.token, 'secret-token');
    final status = await repo.watchStatus().first;
    expect(status?.login, 'me');
    expect(status?.connected, isTrue);
    expect(status?.trackedRepositories, 2);

    final dump = await db
        .customSelect('SELECT * FROM data_sources')
        .map((r) => r.data.toString())
        .get();
    expect(dump.join(), isNot(contains('secret-token')));
  });

  test('the first sync reaches back 30 days', () async {
    await repo.completeConnection('t', 'repo');
    await repo.sync();
    expect(client.lastSince, now.subtract(const Duration(days: 30)));
  });

  test('imports activity once, even when re-read', () async {
    await repo.completeConnection('t', 'repo');
    client.activity = [
      commit('a', 'me/app', now.subtract(const Duration(hours: 1))),
    ];

    await repo.sync();
    await repo.sync();

    final rows = await events();
    expect(rows.single.kind, ActivityKind.commit);
    expect(rows.single.domain, 'me/app');
    expect(rows.single.category, ActivityCategory.coding);
  });

  test('later syncs resume with a day of overlap', () async {
    await repo.completeConnection('t', 'repo');
    await repo.sync();
    final first = now;
    now = now.add(const Duration(hours: 5));
    await repo.sync();
    expect(client.lastSince, first.subtract(const Duration(days: 1)));
  });

  test('an ignored repository is purged and stays out', () async {
    await repo.completeConnection('t', 'repo');
    client.activity = [
      commit('a', 'me/dotfiles', now.subtract(const Duration(hours: 1))),
    ];
    await repo.sync();
    expect(await events(), hasLength(1));

    final dotfiles = (await repo.watchRepositories().first).firstWhere(
      (r) => r.fullName == 'me/dotfiles',
    );
    await repo.setRepositoryIgnored(dotfiles, ignored: true);
    expect(await events(), isEmpty);

    await repo.sync();
    expect(await events(), isEmpty);
    expect((await repo.watchStatus().first)?.ignoredRepositories, 1);
  });

  test('nothing syncs during a private session', () async {
    await repo.completeConnection('t', 'repo');
    await db.writeSetting(privateSessionSettingKey, 'true');
    await repo.sync();
    expect(client.lastSince, isNull);
  });

  test('activity from a private stretch is not imported afterwards', () async {
    await repo.completeConnection('t', 'repo');
    await repo.sync();

    final privateEnd = now.add(const Duration(hours: 3));
    await db.writeSetting(
      importFloorSettingKey,
      '${privateEnd.millisecondsSinceEpoch}',
    );
    now = now.add(const Duration(hours: 5));
    client.activity = [
      commit('during', 'me/app', privateEnd.subtract(const Duration(hours: 1))),
      commit('after', 'me/app', privateEnd.add(const Duration(hours: 1))),
    ];
    await repo.sync();

    expect((await events()).map((e) => e.externalId), ['commit:after']);
  });

  test('a deleted event stays deleted', () async {
    await repo.completeConnection('t', 'repo');
    client.activity = [
      commit('a', 'me/app', now.subtract(const Duration(hours: 1))),
    ];
    await repo.sync();
    final source = await db.select(db.dataSources).getSingle();
    await db.delete(db.activityEvents).go();
    await db
        .into(db.eventTombstones)
        .insert(
          EventTombstonesCompanion.insert(
            sourceId: source.id,
            externalId: 'commit:a',
            deletedAt: now,
          ),
        );

    await repo.sync();
    expect(await events(), isEmpty);
  });

  test('a rejected token asks for reconnection', () async {
    await repo.completeConnection('t', 'repo');
    client.failure = const GitHubFailure(GitHubFailureKind.revoked);

    await expectLater(repo.sync(), throwsA(isA<GitHubFailure>()));

    final status = await repo.watchStatus().first;
    expect(status?.needsReconnect, isTrue);
    expect(status?.connected, isTrue);
  });

  test('disconnecting can keep the events', () async {
    await repo.completeConnection('t', 'repo');
    client.activity = [
      commit('a', 'me/app', now.subtract(const Duration(hours: 1))),
    ];
    await repo.sync();

    await repo.disconnect(keepEvents: true);

    expect(tokens.token, isNull);
    expect(await events(), hasLength(1));
    expect((await repo.watchStatus().first)?.connected, isFalse);

    client.activity = [commit('b', 'me/app', now)];
    await repo.sync();
    expect(await events(), hasLength(1));
  });

  test('disconnecting can delete the events', () async {
    await repo.completeConnection('t', 'repo');
    client.activity = [
      commit('a', 'me/app', now.subtract(const Duration(hours: 1))),
    ];
    await repo.sync();

    await repo.disconnect(keepEvents: false);

    expect(await events(), isEmpty);
    expect(await repo.watchStatus().first, isNull);
    expect(await db.select(db.trackedRepositories).get(), isEmpty);
  });

  group('live polling', () {
    late DateTime pushedAt;

    Future<void> connectAndSync() async {
      await repo.completeConnection('t', 'repo');
      await repo.sync();
      now = now.add(const Duration(minutes: 10));
      pushedAt = now.subtract(const Duration(minutes: 1));
    }

    test('imports commits only from repositories that changed', () async {
      await connectAndSync();
      client
        ..pushed = PushedRepositories('tag1', [
          PushedRepository('me/app', pushedAt),
          PushedRepository('me/old', now.subtract(const Duration(days: 40))),
        ])
        ..recent = {
          'me/app': [commit('new', 'me/app', pushedAt)],
        };

      await repo.pollForPushes();

      expect(client.polledRepositories, ['me/app']);
      expect((await events()).single.externalId, 'commit:new');
    });

    test('an unchanged answer does nothing and reuses the etag', () async {
      await connectAndSync();
      client.pushed = const PushedRepositories('tag1', []);
      await repo.pollForPushes();
      expect(client.seenEtag, isNull);

      client.pushed = null;
      await repo.pollForPushes();
      expect(client.seenEtag, 'tag1');
      expect(client.polledRepositories, isEmpty);
    });

    test('does not duplicate what a full sync already found', () async {
      await repo.completeConnection('t', 'repo');
      client.activity = [commit('same', 'me/app', now)];
      await repo.sync();
      now = now.add(const Duration(minutes: 10));
      client
        ..pushed = PushedRepositories('t', [PushedRepository('me/app', now)])
        ..recent = {
          'me/app': [commit('same', 'me/app', now)],
        };

      await repo.pollForPushes();
      expect(await events(), hasLength(1));
    });

    test('skips ignored repositories', () async {
      await connectAndSync();
      final dotfiles = (await repo.watchRepositories().first).firstWhere(
        (r) => r.fullName == 'me/dotfiles',
      );
      await repo.setRepositoryIgnored(dotfiles, ignored: true);
      client.pushed = PushedRepositories('t', [
        PushedRepository('me/dotfiles', pushedAt),
      ]);

      await repo.pollForPushes();
      expect(client.polledRepositories, isEmpty);
    });

    test('does nothing before the first sync or while private', () async {
      await repo.completeConnection('t', 'repo');
      client.pushed = PushedRepositories('t', [
        PushedRepository('me/app', now),
      ]);
      await repo.pollForPushes();
      expect(client.polledRepositories, isEmpty);

      await repo.sync();
      now = now.add(const Duration(minutes: 10));
      await db.writeSetting(privateSessionSettingKey, 'true');
      client.pushed = PushedRepositories('t', [
        PushedRepository('me/app', now),
      ]);
      await repo.pollForPushes();
      expect(client.polledRepositories, isEmpty);
    });

    test('commits from a private stretch stay out', () async {
      await connectAndSync();
      final floor = now.subtract(const Duration(minutes: 2));
      await db.writeSetting(
        importFloorSettingKey,
        '${floor.millisecondsSinceEpoch}',
      );
      client
        ..pushed = PushedRepositories('t', [PushedRepository('me/app', now)])
        ..recent = {
          'me/app': [
            commit(
              'during',
              'me/app',
              floor.subtract(const Duration(hours: 1)),
            ),
            commit('after', 'me/app', now),
          ],
        };

      await repo.pollForPushes();
      expect((await events()).map((e) => e.externalId), ['commit:after']);
    });

    test('a rejected token stops polling and asks to reconnect', () async {
      await connectAndSync();
      client.failure = const GitHubFailure(GitHubFailureKind.revoked);

      await expectLater(repo.pollForPushes(), throwsA(isA<GitHubFailure>()));
      expect((await repo.watchStatus().first)?.needsReconnect, isTrue);
    });
  });

  test('repository stats count activity and leave out private events', () {
    final at = DateTime(2026, 11, 9, 10);
    TrackedActivity item(
      ActivityKind kind, {
      DateTime? end,
      bool isPrivate = false,
    }) => TrackedActivity(
      id: '$kind',
      kind: kind,
      category: ActivityCategory.coding,
      title: 't',
      start: at,
      end: end,
      isPrivate: isPrivate,
    );

    final stats = RepositoryStats.from([
      item(ActivityKind.commit),
      item(ActivityKind.commit),
      item(ActivityKind.pullRequest),
      item(ActivityKind.review),
      item(ActivityKind.issue),
      item(
        ActivityKind.codingSession,
        end: at.add(const Duration(minutes: 30)),
      ),
      item(ActivityKind.commit, isPrivate: true),
    ]);

    expect(stats.commits, 2);
    expect(stats.pullRequests, 1);
    expect(stats.reviews, 1);
    expect(stats.issues, 1);
    expect(stats.codingTime, const Duration(minutes: 30));
    expect(stats.lastActivity, at);
    expect(RepositoryStats.from(const []).lastActivity, isNull);
  });

  test('reconnecting reuses the same source', () async {
    await repo.completeConnection('t', 'repo');
    await db
        .update(db.dataSources)
        .write(const DataSourcesCompanion(status: Value(SourceStatus.error)));

    await repo.completeConnection('t2', 'repo');

    expect(await db.select(db.dataSources).get(), hasLength(1));
    expect(tokens.token, 't2');
    expect((await repo.watchStatus().first)?.needsReconnect, isFalse);
  });
}
