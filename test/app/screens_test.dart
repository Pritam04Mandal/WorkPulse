import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workpulse/app/app.dart';
import 'package:workpulse/app/router.dart';
import 'package:workpulse/core/database/app_database.dart';
import 'package:workpulse/core/database/setting_keys.dart';
import 'package:workpulse/core/domain/enums.dart';
import 'package:workpulse/features/auth/data/auth_repository_impl.dart';
import 'package:workpulse/features/auth/domain/auth_contracts.dart';
import 'package:workpulse/features/auth/domain/auth_models.dart';
import 'package:workpulse/features/auth/presentation/session_controller.dart';
import 'package:workpulse/features/tracking/data/usage_gateway.dart';
import 'package:workpulse/features/tracking/domain/usage_models.dart';
import 'package:workpulse/features/tracking/presentation/tracking_controller.dart';
import 'package:workpulse/features/settings/presentation/profile_screen.dart';

class _NullTokens implements TokenStore {
  final cleared = <AuthProvider>[];

  @override
  Future<void> clear(AuthProvider provider) async => cleared.add(provider);

  @override
  Future<void> saveIdToken(AuthProvider provider, String? token) async {}
}

class _Gateway implements UsageAccessGateway {
  @override
  Future<bool> isGranted() async => true;

  @override
  Future<void> openSettings() async {}

  @override
  Future<List<RawUsageEvent>> queryEvents(int startMs, int endMs) async => [];

  @override
  Future<Map<String, String>> appLabels(List<String> packages) async => {};

  @override
  Future<List<InstalledApp>> launchableApps() async => const [
    InstalledApp('com.android.chrome', 'Chrome'),
  ];

  @override
  Future<Set<String>> homePackages() async => {};
}

class _FakeProvider implements IdentityProvider {
  @override
  bool get isConfigured => true;

  @override
  Future<ProviderIdentity> signIn() async =>
      const ProviderIdentity(subjectId: 'subject-123456789', name: 'Ada');

  @override
  Future<ProviderIdentity?> restore() async => null;

  @override
  Future<void> signOut() async {}
}

Future<void> _loadFont(String family, String asset) async {
  final loader = FontLoader(family)..addFont(rootBundle.load(asset));
  await loader.load();
}

/// The real sync is covered by the repository tests. Here it would run inside
/// the widget test's fake clock and never finish.
class _IdleTracking extends TrackingController {
  @override
  Future<void> refresh() async {}
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Real metrics, so overflow failures reflect what a phone would show.
    await _loadFont('Inter', 'assets/fonts/Inter-400.ttf');
    await _loadFont('JetBrains Mono', 'assets/fonts/JetBrainsMono-400.ttf');
  });

  late AppDatabase db;
  late ProviderContainer container;
  late AuthRepositoryImpl repository;

  Future<void> pumpApp(WidgetTester tester, {UserProfile? user}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);

    db = AppDatabase(NativeDatabase.memory());
    repository = AuthRepositoryImpl(
      database: db,
      tokens: _NullTokens(),
      providers: {AuthProvider.google: _FakeProvider()},
    );
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        trackingControllerProvider.overrideWith(_IdleTracking.new),
        authRepositoryProvider.overrideWithValue(repository),
        usageAccessGatewayProvider.overrideWithValue(_Gateway()),
        initialSessionProvider.overrideWithValue(
          Session(user: user, onboardingComplete: true),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const WorkPulseApp(),
      ),
    );
    await tester.pump();
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    // Drift finishes through timers, which only run when the fake clock moves.
    final closing = db.close();
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await closing;
  }

  final sampleRoutes = <String, String>{
    '/projects': 'Projects',
    '/insights': 'Insights',
    '/projects/workpulse-app': 'workpulse-app',
    '/projects/client-meetings': 'Client meetings',
    '/projects/new': 'New project',
    '/projects/billing-api/edit': 'Edit project',
    '/home/journal': 'Main projects',
    '/integrations': 'Integrations',
    '/integrations/github': 'Connected as @sample-dev',
    '/integrations/github/connect': 'Connect GitHub',
    '/integrations/teams': 'Microsoft Teams',
    '/integrations/pair': 'Pair a device',
  };

  for (final MapEntry(key: route, value: expected) in sampleRoutes.entries) {
    testWidgets('$route renders, labelled as sample data', (tester) async {
      await pumpApp(tester);
      container.read(routerProvider).go(route);
      await settle(tester);

      expect(find.textContaining(expected), findsWidgets);
      expect(find.text('SAMPLE DATA').hitTestable(), findsWidgets);
      await finish(tester);
    });
  }

  for (final (route, expected) in const [
    ('/home', 'Today'),
    ('/timeline', 'Timeline'),
    ('/settings', 'Settings'),
    ('/settings/exclusions', 'Chrome'),
    ('/settings/profile', 'Local profile'),
    ('/settings/delete-data', 'Delete all data'),
    ('/integrations/add-git', 'Add Git instance'),
    ('/usage-access', 'Allow Usage Access'),
  ]) {
    testWidgets('$route renders', (tester) async {
      await pumpApp(tester);
      container.read(routerProvider).go(route);
      await settle(tester);

      expect(find.textContaining(expected), findsWidgets);
      await finish(tester);
    });
  }

  testWidgets('the timeline shows real events and filters them', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.runAsync(() async {
      final source = await db
          .into(db.dataSources)
          .insertReturning(
            DataSourcesCompanion.insert(
              kind: SourceKind.androidUsage,
              status: SourceStatus.connected,
              connectedAt: DateTime.now(),
            ),
          );
      final now = DateTime.now();
      await db
          .into(db.activityEvents)
          .insert(
            ActivityEventsCompanion.insert(
              sourceId: source.id,
              kind: ActivityKind.appUsage,
              category: ActivityCategory.other,
              title: 'Chrome',
              startedAt: DateTime(now.year, now.month, now.day),
              endedAt: Value(DateTime(now.year, now.month, now.day, 0, 20)),
            ),
          );
    });
    container.read(routerProvider).go('/timeline');
    await settle(tester);
    await settle(tester);

    expect(find.text('Chrome'), findsOneWidget);
    expect(find.text('SAMPLE DATA'), findsNothing);

    await tester.tap(find.text('AI'));
    await tester.pump();
    expect(find.text('Chrome'), findsNothing);
    expect(find.text('Nothing recorded'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('a new project appears in the list', (tester) async {
    await pumpApp(tester);
    container.read(routerProvider).go('/projects/new');
    await settle(tester);

    await tester.enterText(find.byType(TextField).first, 'mobile-release');
    await tester.pump();
    await tester.tap(find.text('Create project'));
    await settle(tester);

    expect(find.text('mobile-release'), findsWidgets);
    expect(find.textContaining('~/code/mobile-release'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('delete requires typing DELETE and wipes the database', (
    tester,
  ) async {
    final user = UserProfile(
      id: 'local',
      provider: AuthProvider.local,
      createdAt: DateTime(2026),
      lastLoginAt: DateTime(2026),
    );
    await pumpApp(tester, user: user);
    await tester.runAsync(() async {
      await repository.continueWithoutAccount();
      await db.writeSetting(onboardingCompleteSettingKey, 'true');
    });
    container.read(routerProvider).go('/settings/delete-data');
    await settle(tester);

    FilledButton deleteButton() => tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Delete everything'),
    );
    expect(deleteButton().onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'delete');
    await tester.pump();
    expect(deleteButton().onPressed, isNotNull);

    await tester.tap(find.text('Delete everything'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await settle(tester);

    expect(find.text('All local data deleted'), findsOneWidget);
    await tester.runAsync(() async {
      expect(await db.select(db.users).get(), isEmpty);
      expect(await db.readSetting(onboardingCompleteSettingKey), isNull);
      expect(await db.readSetting(importFloorSettingKey), isNotNull);
    });

    await tester.tap(find.text('Start over'));
    await settle(tester);
    expect(find.text('Continue without account'), findsOneWidget);
    await finish(tester);
  });

  test('shortId keeps both ends', () {
    expect(shortId('7f3c2a91-1111-2222-3333-44445555e04b'), '7f3c2a91…e04b');
    expect(shortId('short'), 'short');
  });
}
