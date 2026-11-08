import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workpulse/app/app.dart';
import 'package:workpulse/app/router.dart';
import 'package:workpulse/core/database/app_database.dart';
import 'package:workpulse/core/domain/enums.dart';
import 'package:workpulse/core/format/durations.dart';
import 'package:workpulse/features/auth/data/auth_repository_impl.dart';
import 'package:workpulse/features/auth/domain/auth_contracts.dart';
import 'package:workpulse/features/auth/domain/auth_models.dart';
import 'package:workpulse/features/auth/presentation/session_controller.dart';
import 'package:workpulse/features/companion/presentation/companion_controller.dart';
import 'package:workpulse/features/github/presentation/github_controller.dart';
import 'package:workpulse/features/tracking/data/usage_gateway.dart';
import 'package:workpulse/features/tracking/domain/usage_models.dart';
import 'package:workpulse/features/tracking/presentation/tracking_controller.dart';

class _NullTokens implements TokenStore {
  @override
  Future<void> clear(AuthProvider provider) async {}

  @override
  Future<void> saveIdToken(AuthProvider provider, String? token) async {}
}

class _UnconfiguredProvider implements IdentityProvider {
  @override
  bool get isConfigured => false;

  @override
  Future<ProviderIdentity> signIn() async =>
      throw const AuthFailure(AuthFailureKind.notConfigured);

  @override
  Future<ProviderIdentity?> restore() async => null;

  @override
  Future<void> signOut() async {}
}

class _DeniedUsageAccess implements UsageAccessGateway {
  @override
  Future<bool> isGranted() async => false;

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

/// The real sync is covered by the repository tests. Here it would run inside
/// the widget test's fake clock and never finish.
class _IdleTracking extends TrackingController {
  @override
  Future<void> refresh() async {}
}

class _IdleCompanion extends CompanionController {
  @override
  Future<void> resume() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> beginPairing() async {}

  @override
  void cancelPairing() {}
}

class _IdleGitHub extends GitHubSync {
  @override
  Future<void> refresh({bool force = false}) async {}

  @override
  void startLive() {}

  @override
  void stopLive() {}
}

void main() {
  group('onboardingRedirect', () {
    String? redirect(bool done, String location) =>
        onboardingRedirect(onboardingComplete: done, location: location);

    test('sends new users to welcome', () {
      expect(redirect(false, '/home'), '/welcome');
    });
    test('lets new users move through onboarding', () {
      expect(redirect(false, '/sign-in/google'), isNull);
      expect(redirect(false, '/usage-access'), isNull);
    });
    test('keeps finished users off Welcome but allows re-entry points', () {
      expect(redirect(true, '/welcome'), '/home');
      expect(redirect(true, '/timeline'), isNull);
      expect(redirect(true, '/usage-access'), isNull);
      expect(redirect(true, '/sign-in/google'), isNull);
    });
  });

  test('formatDuration matches the design', () {
    expect(formatDuration(const Duration(minutes: 342)), '5h 42m');
    expect(formatDuration(const Duration(minutes: 65)), '1h 05m');
    expect(formatDuration(const Duration(minutes: 40)), '40m');
    expect(formatDuration(null), '—');
    expect(formatElapsed(const Duration(seconds: 7)), '7s');
    expect(formatElapsed(const Duration(seconds: 493)), '8m 13s');
    expect(
      formatElapsed(const Duration(minutes: 65, seconds: 2)),
      '1h 05m 02s',
    );
    expect(formatDuration(const Duration(seconds: 20)), '<1m');
    expect(formatDuration(Duration.zero), '0m');
  });

  group('app', () {
    late AppDatabase db;
    late ProviderContainer container;

    Future<void> pumpApp(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      db = AppDatabase(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          trackingControllerProvider.overrideWith(_IdleTracking.new),
          githubSyncProvider.overrideWith(_IdleGitHub.new),
          companionControllerProvider.overrideWith(_IdleCompanion.new),
          authRepositoryProvider.overrideWithValue(
            AuthRepositoryImpl(
              database: db,
              tokens: _NullTokens(),
              providers: {
                AuthProvider.google: _UnconfiguredProvider(),
                AuthProvider.microsoft: _UnconfiguredProvider(),
              },
            ),
          ),
          usageAccessGatewayProvider.overrideWithValue(_DeniedUsageAccess()),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const WorkPulseApp(),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> tearDownApp(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox());
      container.dispose();
      // Drift finishes through timers, which only run when the fake clock moves.
      final closing = db.close();
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await closing;
    }

    Future<void> tapAndSettle(WidgetTester tester, String label) async {
      await tester.runAsync(() async {
        await tester.tap(find.text(label));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();
    }

    testWidgets('continuing without an account reaches the dashboard', (
      tester,
    ) async {
      await pumpApp(tester);
      expect(find.text('WorkPulse'), findsOneWidget);
      expect(find.textContaining('Microsoft'), findsNothing);
      expect(find.textContaining('Gmail'), findsNothing);

      await tapAndSettle(tester, 'Continue without account');
      expect(find.text('Allow Usage Access'), findsOneWidget);

      await tapAndSettle(tester, 'Not now');
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('ACTIVE TRACKING'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      await tester.runAsync(() async {
        final users = await db.select(db.users).get();
        expect(users.single.provider, AuthProvider.local);
        expect(await db.readSetting(onboardingCompleteSettingKey), 'true');
      });
      await tearDownApp(tester);
    });

    testWidgets('an unconfigured provider shows an error, not a crash', (
      tester,
    ) async {
      await pumpApp(tester);

      await tapAndSettle(tester, 'Continue with Google');

      expect(find.text('Google sign-in isn’t configured'), findsOneWidget);
      expect(find.text('Try again'), findsNothing);
      expect(find.text('Continue without account'), findsOneWidget);
      await tearDownApp(tester);
    });
  });
}
