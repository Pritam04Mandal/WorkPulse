import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workpulse/app/app.dart';
import 'package:workpulse/app/router.dart';
import 'package:workpulse/core/database/app_database.dart';
import 'package:workpulse/core/domain/enums.dart';
import 'package:workpulse/core/format/durations.dart';
import 'package:workpulse/core/theme/tokens.dart';
import 'package:workpulse/features/auth/data/auth_repository_impl.dart';
import 'package:workpulse/features/auth/domain/auth_contracts.dart';
import 'package:workpulse/features/auth/domain/auth_models.dart';
import 'package:workpulse/features/auth/presentation/session_controller.dart';
import 'package:workpulse/features/dashboard/data/sample_dashboard.dart';
import 'package:workpulse/features/onboarding/data/usage_access_gateway.dart';

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
  });

  test('sample categories add up to the design total', () {
    expect(formatDuration(sampleDashboard.activeTime), '5h 42m');
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
      await db.close();
      await tester.pump(Duration.zero);
    }

    Future<void> tapAndSettle(WidgetTester tester, String label) async {
      await tester.runAsync(() async {
        await tester.tap(find.text(label));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();
    }

    testWidgets('continuing without an account reaches a labelled dashboard', (
      tester,
    ) async {
      await pumpApp(tester);
      expect(find.text('WorkPulse'), findsOneWidget);

      await tapAndSettle(tester, 'Continue without account');
      expect(find.text('Allow Usage Access'), findsOneWidget);

      await tapAndSettle(tester, 'Not now');
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('SAMPLE DATA'), findsOneWidget);
      expect(find.text('5h 42m'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      final codingBar = find.byWidgetPredicate(
        (w) => w is ColoredBox && w.color == AppColors.coding,
      );
      expect(tester.getSize(codingBar).height, 8);

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
