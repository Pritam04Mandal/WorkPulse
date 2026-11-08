import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workpulse/core/database/app_database.dart';
import 'package:workpulse/core/database/setting_keys.dart';
import 'package:workpulse/core/domain/enums.dart';
import 'package:workpulse/features/dashboard/domain/dashboard_summary.dart';
import 'package:workpulse/features/timeline/domain/timeline_builder.dart';
import 'package:workpulse/features/timeline/domain/timeline_entry.dart';
import 'package:workpulse/features/tracking/data/tracking_repository.dart';
import 'package:workpulse/features/tracking/data/usage_gateway.dart';
import 'package:workpulse/features/tracking/domain/usage_models.dart';

class FakeGateway implements UsageAccessGateway {
  bool granted = true;
  List<RawUsageEvent> events = [];
  int? lastStart;

  @override
  Future<bool> isGranted() async => granted;

  @override
  Future<void> openSettings() async {}

  @override
  Future<List<RawUsageEvent>> queryEvents(int startMs, int endMs) async {
    lastStart = startMs;
    return events.where((e) => e.timeMs >= startMs).toList();
  }

  @override
  Future<Map<String, String>> appLabels(List<String> packages) async => {
    for (final p in packages) p: 'App $p',
  };

  @override
  Future<List<InstalledApp>> launchableApps() async => const [];

  @override
  Future<Set<String>> homePackages() async => {'launcher'};
}

void main() {
  late AppDatabase db;
  late FakeGateway gateway;
  late TrackingRepository repo;
  var now = DateTime(2026, 11, 9, 12);

  int at(int hour, int minute) =>
      DateTime(2026, 11, 9, hour, minute).millisecondsSinceEpoch;

  List<RawUsageEvent> session(String package, int startMs, int endMs) => [
    RawUsageEvent(package, UsageEventType.resumed, startMs),
    RawUsageEvent(package, UsageEventType.paused, endMs),
  ];

  Future<List<TrackedActivity>> today() =>
      repo.watchDay(DateTime(2026, 11, 9)).first;

  setUp(() {
    now = DateTime(2026, 11, 9, 12);
    db = AppDatabase(NativeDatabase.memory());
    gateway = FakeGateway();
    repo = TrackingRepository(database: db, gateway: gateway, clock: () => now);
  });
  tearDown(() => db.close());

  test('the first sync reads from the start of today only', () async {
    await repo.sync();
    expect(gateway.lastStart, DateTime(2026, 11, 9).millisecondsSinceEpoch);
  });

  test('imports sessions with their labels and category', () async {
    gateway.events = session('com.openai.chatgpt', at(10, 0), at(10, 30));
    await repo.sync();

    final activity = (await today()).single;
    expect(activity.title, 'App com.openai.chatgpt');
    expect(activity.category, ActivityCategory.ai);
    expect(activity.duration, const Duration(minutes: 30));
  });

  test('syncing twice does not duplicate events', () async {
    gateway.events = session('a', at(10, 0), at(10, 30));
    await repo.sync();
    await db
        .update(db.dataSources)
        .write(const DataSourcesCompanion(syncCursor: Value(null)));
    await repo.sync();
    expect(await today(), hasLength(1));
  });

  test('launchers, WorkPulse and system UI are ignored', () async {
    gateway.events = [
      ...session('launcher', at(9, 0), at(9, 10)),
      ...session('com.workpulse.app', at(9, 20), at(9, 30)),
      ...session('com.android.systemui', at(9, 40), at(9, 50)),
    ];
    await repo.sync();
    expect(await today(), isEmpty);
  });

  test('nothing is read without Usage Access', () async {
    gateway
      ..granted = false
      ..events = session('a', at(10, 0), at(10, 30));

    expect(await repo.sync(), isFalse);
    expect(await today(), isEmpty);
    expect(gateway.lastStart, isNull);
  });

  test('excluding an app deletes its history and blocks new events', () async {
    gateway.events = session('a', at(10, 0), at(10, 30));
    await repo.sync();

    await repo.setAppExcluded(const InstalledApp('a', 'A'), excluded: true);
    expect(await today(), isEmpty);

    gateway.events = session('a', at(11, 0), at(11, 30));
    await repo.sync();
    expect(await today(), isEmpty);
    expect(await repo.watchExcludedApps().first, {'a'});
  });

  test('a deleted event is not imported again', () async {
    gateway.events = session('a', at(10, 0), at(10, 30));
    await repo.sync();
    await repo.deleteActivity((await today()).single.id);

    await db
        .update(db.dataSources)
        .write(const DataSourcesCompanion(syncCursor: Value(null)));
    await repo.sync();
    expect(await today(), isEmpty);
  });

  test('nothing from a private session is ever imported', () async {
    gateway.events = session('before', at(10, 0), at(10, 30));
    now = DateTime(2026, 11, 9, 11);
    await repo.setPrivateSession(true);
    expect((await today()).single.application, 'before');

    gateway.events = [
      ...gateway.events,
      ...session('secret', at(11, 10), at(11, 40)),
    ];
    now = DateTime(2026, 11, 9, 12);
    await repo.sync();
    expect(await today(), hasLength(1));

    await repo.setPrivateSession(false);
    now = DateTime(2026, 11, 9, 13);
    await repo.sync();
    final apps = (await today()).map((a) => a.application);
    expect(apps, isNot(contains('secret')));
  });

  test('the import floor keeps wiped activity from coming back', () async {
    gateway.events = session('a', at(10, 0), at(10, 30));
    await db.writeSetting(importFloorSettingKey, '${at(11, 0)}');
    await repo.sync();

    expect(gateway.lastStart, at(11, 0));
    expect(await today(), isEmpty);
  });

  test('catch-up is limited to what Android retains', () async {
    await db
        .into(db.dataSources)
        .insert(
          DataSourcesCompanion.insert(
            kind: SourceKind.androidUsage,
            status: SourceStatus.connected,
            connectedAt: now,
            syncCursor: const Value('1000'),
          ),
        );
    await repo.sync();
    expect(
      gateway.lastStart,
      now.subtract(const Duration(days: 7)).millisecondsSinceEpoch,
    );
  });

  test('correcting times marks the event', () async {
    gateway.events = session('a', at(10, 0), at(10, 30));
    await repo.sync();
    final id = (await today()).single.id;

    await repo.correctTimes(
      id,
      DateTime(2026, 11, 9, 10, 5),
      DateTime(2026, 11, 9, 10, 15),
    );
    final activity = (await today()).single;
    expect(activity.isCorrected, isTrue);
    expect(activity.duration, const Duration(minutes: 10));
  });

  group('derived views', () {
    TrackedActivity activity(
      String title,
      int startMinute,
      int minutes, {
      ActivityCategory category = ActivityCategory.other,
      bool isPrivate = false,
    }) {
      final start = DateTime(2026, 11, 9, 9, startMinute);
      return TrackedActivity(
        id: title,
        kind: ActivityKind.appUsage,
        category: category,
        title: title,
        start: start,
        end: start.add(Duration(minutes: minutes)),
        isPrivate: isPrivate,
      );
    }

    test('Home totals leave out private events', () {
      final summary = buildDashboardSummary([
        activity('Chrome', 0, 20),
        activity('Secret', 25, 40, isPrivate: true),
        activity('ChatGPT', 70, 10, category: ActivityCategory.ai),
      ], usageGranted: true);

      expect(summary.activeTime, const Duration(minutes: 30));
      expect(summary.tiles.first.value, '2');
      expect(summary.latest?.title, 'ChatGPT');
      expect(summary.tiles.last.caption, 'ChatGPT 1');
      expect(summary.dailySummary, contains('Chrome (20m)'));
    });

    test('an empty day gives an honest summary', () {
      final summary = buildDashboardSummary(const [], usageGranted: false);
      expect(summary.latest, isNull);
      expect(summary.dailySummary, 'Nothing recorded yet today.');
      expect(summary.integrationsLabel, 'No sources connected');
    });

    test('the timeline adds gaps and hides private details', () {
      final rows = buildTimelineEntries([
        activity('Chrome', 0, 10),
        activity('Maps', 15, 5),
        activity('Bank', 60, 10, isPrivate: true),
      ]);

      expect(rows.map((r) => r.kind), [
        EntryKind.other,
        EntryKind.other,
        EntryKind.gap,
        EntryKind.private,
      ]);
      expect(rows.last.title, 'Private session');
      expect(rows.map((r) => r.title), isNot(contains('Bank')));
      expect(trackedTime(rows), const Duration(minutes: 15));
      expect(gapTime(rows), const Duration(minutes: 40));
    });
  });
}
