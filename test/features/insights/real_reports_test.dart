import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workpulse/core/database/app_database.dart' hide Project;
import 'package:workpulse/core/domain/enums.dart';
import 'package:workpulse/features/insights/domain/insights_data.dart';
import 'package:workpulse/features/journal/domain/journal_report.dart';
import 'package:workpulse/features/projects/data/project_repository.dart';
import 'package:workpulse/features/projects/domain/project.dart';
import 'package:workpulse/features/projects/domain/project_matcher.dart';
import 'package:workpulse/features/tracking/domain/usage_models.dart';

// Monday 9 November 2026.
final monday = DateTime(2026, 11, 9);

TrackedActivity timed(
  String title, {
  int dayOffset = 0,
  int hour = 9,
  int minutes = 60,
  ActivityKind kind = ActivityKind.appUsage,
  ActivityCategory category = ActivityCategory.other,
  String? repository,
  String? application,
  bool isPrivate = false,
}) {
  final start = DateTime(2026, 11, 9 + dayOffset, hour);
  return TrackedActivity(
    id: title,
    kind: kind,
    category: category,
    title: title,
    start: start,
    end: start.add(Duration(minutes: minutes)),
    repository: repository,
    application: application,
    isPrivate: isPrivate,
  );
}

TrackedActivity commit(String title, String repository) => TrackedActivity(
  id: title,
  kind: ActivityKind.commit,
  category: ActivityCategory.coding,
  title: title,
  start: monday.add(const Duration(hours: 10)),
  repository: repository,
);

const app = Project(
  id: 'p1',
  name: 'app',
  colorHex: '#3DD6B0',
  repository: 'github.com/me/app',
);

void main() {
  group('matching', () {
    Project rule(RuleKind kind, String value) => Project(
      id: 'p',
      name: 'x',
      colorHex: '#3DD6B0',
      rules: [ProjectRuleItem(kind, value)],
    );

    test('a project repository matches however it was typed', () {
      final event = commit('c', 'me/app');
      for (final repository in [
        'github.com/me/app',
        'https://github.com/me/app.git',
        'me/app',
        'ME/App/',
        'git@github.com:me/app.git',
      ]) {
        final project = Project(
          id: 'p',
          name: 'x',
          colorHex: '#3DD6B0',
          repository: repository,
        );
        expect(matchProject(event, [project]), project, reason: repository);
      }
    });

    test('an owner with a dot in its name survives', () {
      expect(normalizeRepository('my.org/app'), 'my.org/app');
    });

    test('a project can link several repositories', () {
      const project = Project(
        id: 'p',
        name: 'x',
        colorHex: '#3DD6B0',
        repository: 'github.com/me/app',
        rules: [
          ProjectRuleItem(RuleKind.repo, 'github.com/me/api'),
          ProjectRuleItem(RuleKind.repo, 'gitlab.com/team/web'),
        ],
      );
      expect(project.repositories, hasLength(3));
      for (final name in ['me/app', 'me/api', 'team/web']) {
        expect(
          matchProject(commit('c', name), [project]),
          project,
          reason: name,
        );
      }
      expect(matchProject(commit('c', 'me/other'), [project]), isNull);
    });

    test('a path rule matches the folder of a coding session', () {
      final session = timed(
        'VS Code · mobile',
        kind: ActivityKind.codingSession,
      );
      expect(
        matchProject(session, [rule(RuleKind.path, '~/code/mobile/**')]),
        isNotNull,
      );
      expect(matchProject(session, [rule(RuleKind.path, 'other')]), isNull);
    });

    test('app and title rules match', () {
      final event = timed('Termux', application: 'com.termux');
      expect(
        matchProject(event, [rule(RuleKind.app, 'com.termux')]),
        isNotNull,
      );
      expect(matchProject(event, [rule(RuleKind.title, 'term')]), isNotNull);
    });

    test('an app rule accepts the name people see', () {
      final event = timed('Chrome', application: 'com.android.chrome');
      expect(matchProject(event, [rule(RuleKind.app, 'Chrome')]), isNotNull);
      expect(
        matchProject(event, [rule(RuleKind.app, 'com.android.chrome')]),
        isNotNull,
      );
      expect(matchProject(event, [rule(RuleKind.app, 'Firefox')]), isNull);
    });

    test('a few seconds of use is not rounded away', () {
      final event = timed('Chrome', minutes: 0);
      final short = TrackedActivity(
        id: 'a',
        kind: event.kind,
        category: event.category,
        title: 'Chrome',
        start: event.start,
        end: event.start.add(const Duration(seconds: 16)),
      );
      expect(
        ProjectStats.from([short], monday).week,
        const Duration(seconds: 16),
      );
    });

    test('private events belong to no project', () {
      final event = timed('Termux', isPrivate: true, application: 'com.termux');
      expect(matchProject(event, [rule(RuleKind.app, 'com.termux')]), isNull);
    });
  });

  group('default usage project', () {
    const usage = Project(
      id: usageProjectId,
      name: usageProjectName,
      colorHex: usageProjectColor,
    );
    TrackedActivity phoneApp(String package) =>
        timed(package, application: package);

    test('collects system apps', () {
      for (final package in [
        'com.android.settings',
        'com.google.android.dialer',
        'com.android.server.telecom',
        'com.google.android.contacts',
        'com.google.android.apps.messaging',
        'com.oplus.camera',
        'com.google.android.deskclock',
      ]) {
        expect(
          matchProject(phoneApp(package), [usage]),
          usage,
          reason: package,
        );
      }
    });

    test('leaves ordinary apps alone', () {
      for (final package in [
        'com.android.chrome',
        'com.whatsapp',
        'com.google.android.youtube',
      ]) {
        expect(
          matchProject(phoneApp(package), [usage]),
          isNull,
          reason: package,
        );
      }
    });

    test('a project of your own wins over it', () {
      const mine = Project(
        id: 'p',
        name: 'Mine',
        colorHex: '#3DD6B0',
        rules: [ProjectRuleItem(RuleKind.app, 'com.android.settings')],
      );
      expect(
        matchProject(phoneApp('com.android.settings'), [mine, usage]),
        mine,
      );
    });

    test('never takes coding sessions or private events', () {
      final session = timed(
        'VS Code · x',
        kind: ActivityKind.codingSession,
        application: 'com.android.settings',
      );
      expect(matchProject(session, [usage]), isNull);
      final private = timed(
        'Settings',
        application: 'com.android.settings',
        isPrivate: true,
      );
      expect(matchProject(private, [usage]), isNull);
    });

    test('watching projects settles instead of waking itself', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      var emissions = 0;
      final subscription = ProjectRepository(database: db)
          .watchAll()
          .listen((_) => emissions++);
      addTearDown(subscription.cancel);

      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(emissions, lessThan(4));
    });

    test('exists, comes last and returns after a wipe', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = ProjectRepository(database: db);
      await repo.save(
        const Project(id: 'a', name: 'Mine', colorHex: '#3DD6B0'),
      );

      final projects = await repo.watchAll().first;
      expect(projects.map((p) => p.id), ['a', usageProjectId]);

      await db.delete(db.projects).go();
      expect((await repo.watchAll().first).single.id, usageProjectId);
    });
  });

  group('project repository', () {
    late AppDatabase db;
    late ProjectRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = ProjectRepository(database: db);
    });
    tearDown(() => db.close());

    test('saves, edits rules and deletes', () async {
      const project = Project(
        id: 'p1',
        name: 'app',
        colorHex: '#3DD6B0',
        rules: [ProjectRuleItem(RuleKind.path, 'app')],
      );
      await repo.save(project);
      List<Project> own(List<Project> all) =>
          all.where((p) => !p.isDefault).toList();
      var loaded = own(await repo.watchAll().first);
      expect(loaded.single.rules.single.kind, RuleKind.path);

      await repo.save(
        project.copyWith(
          rules: const [ProjectRuleItem(RuleKind.repo, 'me/app')],
        ),
      );
      loaded = own(await repo.watchAll().first);
      expect(loaded, hasLength(1));
      expect(loaded.single.rules.single.value, 'me/app');

      await repo.delete('p1');
      expect(own(await repo.watchAll().first), isEmpty);
      expect(await db.select(db.projectRules).get(), isEmpty);
    });
  });

  group('insights', () {
    test('groups a week by day and attributes matched time', () {
      final data = buildInsights(
        InsightsPeriod.week,
        [
          timed('A', repository: 'me/app', kind: ActivityKind.codingSession),
          timed('B', dayOffset: 2, minutes: 30),
        ],
        const [app],
        monday,
      );

      expect(data.usage[0], 1);
      expect(data.usage[2], 0.5);
      expect(data.attributed[0], 1);
      expect(data.attributed[2], 0);
      expect(data.usageTotal, const Duration(minutes: 90));
      expect(data.projects.first.name, 'app');
      expect(data.projects.last.name, 'Unassigned');
      expect(data.topApps.single.$1, 'B');
    });

    test('private events are left out', () {
      final data = buildInsights(
        InsightsPeriod.week,
        [timed('Secret', isPrivate: true)],
        const [],
        monday,
      );
      expect(data.isEmpty, isTrue);
      expect(data.topApps, isEmpty);
    });

    test('a day uses four-hour blocks and a month uses weeks', () {
      final day = buildInsights(
        InsightsPeriod.day,
        [timed('A', hour: 13)],
        const [],
        monday,
      );
      expect(day.usage[3], 1);

      final month = buildInsights(
        InsightsPeriod.month,
        [timed('A', dayOffset: 6)],
        const [],
        monday,
      );
      expect(month.labels.first, 'W1');
      expect(month.usage[2], 1);
    });

    test('groups AI assistants by name', () {
      final data = buildInsights(
        InsightsPeriod.week,
        [
          timed('ChatGPT', category: ActivityCategory.ai),
          timed('ChatGPT', category: ActivityCategory.ai, hour: 11),
        ],
        const [],
        monday,
      );
      expect(data.assistants.single.$1, 'ChatGPT');
      expect(data.assistants.single.$2, const Duration(hours: 2));
    });
  });

  group('journal', () {
    test('a day reports real projects, GitHub and coding time', () {
      final report = buildDailyReport(
        [
          timed(
            'VS Code · app',
            kind: ActivityKind.codingSession,
            category: ActivityCategory.coding,
            repository: 'me/app',
          ),
          commit('Commit · Fix it', 'me/app'),
        ],
        const [app],
        monday,
      );

      expect(report.projects.single.$1, 'app');
      expect(report.github.single, contains('Commit · Fix it'));
      expect(report.codingSummary, contains('1h 00m of coding'));
      expect(report.toPlainText(), isNot(contains('sample')));
    });

    test('an empty day says so', () {
      final report = buildDailyReport(const [], const [], monday);
      expect(report.isEmpty, isTrue);
      expect(report.projects, isEmpty);
    });

    test('private events never reach a report', () {
      final report = buildDailyReport(
        [timed('Bank', isPrivate: true)],
        const [],
        monday,
      );
      expect(report.toPlainText(), isNot(contains('Bank')));
    });

    test('a week totals time and finds the busiest day', () {
      final report = buildWeeklyReport(
        [
          timed('A', minutes: 30, repository: 'me/app'),
          timed('B', dayOffset: 1, minutes: 120),
          commit('c', 'me/app'),
        ],
        const [app],
        monday,
      );

      expect(report.tracked, const Duration(minutes: 150));
      expect(report.attributed, const Duration(minutes: 30));
      expect(report.highlights, contains('GitHub: 1 commit'));
      expect(report.highlights.last, contains('Tuesday, 2h 00m'));
    });
  });
}
