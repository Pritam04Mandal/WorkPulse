import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workpulse/core/database/app_database.dart';
import 'package:workpulse/core/database/setting_keys.dart';
import 'package:workpulse/core/theme/app_theme.dart';
import 'package:workpulse/features/auth/presentation/session_controller.dart';
import 'package:workpulse/features/security/data/biometric_gateway.dart';
import 'package:workpulse/features/security/presentation/app_lock.dart';

class FakeGateway implements BiometricGateway {
  AuthOutcome next = AuthOutcome.success;
  int calls = 0;
  Completer<void>? hold;

  @override
  Future<AuthOutcome> authenticate(String reason) async {
    calls++;
    await hold?.future;
    return next;
  }
}

void main() {
  late AppDatabase db;
  late FakeGateway gateway;
  late DateTime now;

  ProviderContainer container({bool enabled = false, bool onboarded = true}) {
    final c = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        biometricGatewayProvider.overrideWithValue(gateway),
        lockClockProvider.overrideWithValue(() => now),
        initialLockEnabledProvider.overrideWithValue(enabled),
        initialSessionProvider.overrideWithValue(
          Session(onboardingComplete: onboarded),
        ),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  AppLockState stateOf(ProviderContainer c) => c.read(appLockProvider);
  AppLockController lock(ProviderContainer c) =>
      c.read(appLockProvider.notifier);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    gateway = FakeGateway();
    now = DateTime(2026, 11, 9, 12);
  });
  tearDown(() => db.close());

  group('turning it on and off', () {
    test('turning on needs a successful check and is saved', () async {
      final c = container();

      expect(await lock(c).setEnabled(true), LockChangeResult.changed);

      expect(stateOf(c).enabled, isTrue);
      expect(stateOf(c).locked, isFalse);
      expect(await db.readSetting(biometricLockSettingKey), 'true');
    });

    test('a cancelled check changes nothing', () async {
      final c = container();
      gateway.next = AuthOutcome.failed;

      expect(await lock(c).setEnabled(true), LockChangeResult.cancelled);

      expect(stateOf(c).enabled, isFalse);
      expect(await db.readSetting(biometricLockSettingKey), isNull);
    });

    test('turning off also needs a check', () async {
      await db.writeSetting(biometricLockSettingKey, 'true');
      final c = container(enabled: true);
      await lock(c).unlock();
      gateway
        ..next = AuthOutcome.failed
        ..calls = 0;

      await lock(c).setEnabled(false);

      expect(gateway.calls, 1);
      expect(stateOf(c).enabled, isTrue);
      expect(await db.readSetting(biometricLockSettingKey), 'true');
    });

    test('a phone with no screen lock is told so', () async {
      final c = container();
      gateway.next = AuthOutcome.unavailable;

      expect(await lock(c).setEnabled(true), LockChangeResult.unavailable);
      expect(stateOf(c).enabled, isFalse);
    });
  });

  group('locking', () {
    test('starts locked when enabled', () {
      expect(stateOf(container(enabled: true)).locked, isTrue);
      expect(stateOf(container()).locked, isFalse);
    });

    test('onboarding is never locked', () {
      final c = container(enabled: true, onboarded: false);
      expect(stateOf(c).locked, isFalse);
    });

    test('a quick return stays unlocked', () async {
      final c = container(enabled: true);
      await lock(c).unlock();
      gateway.calls = 0;

      lock(c).onHidden();
      now = now.add(lockGracePeriod - const Duration(seconds: 1));
      await lock(c).onResumed();

      expect(stateOf(c).locked, isFalse);
      expect(gateway.calls, 0);
    });

    test('returning after the grace period asks again', () async {
      final c = container(enabled: true);
      await lock(c).unlock();
      gateway
        ..calls = 0
        ..next = AuthOutcome.failed;

      lock(c).onHidden();
      now = now.add(lockGracePeriod);
      await lock(c).onResumed();

      expect(gateway.calls, 1);
      expect(stateOf(c).locked, isTrue);
    });

    test('nothing happens when it is off', () async {
      final c = container();
      lock(c).onHidden();
      now = now.add(const Duration(hours: 1));
      await lock(c).onResumed();

      expect(stateOf(c).locked, isFalse);
      expect(gateway.calls, 0);
    });

    test('the prompt itself does not count as leaving', () async {
      final c = container(enabled: true);
      gateway.hold = Completer<void>();
      final unlocking = lock(c).unlock();

      lock(c).onHidden();
      now = now.add(const Duration(minutes: 5));
      await lock(c).onResumed();
      expect(gateway.calls, 1);

      gateway.hold!.complete();
      await unlocking;
      expect(stateOf(c).locked, isFalse);
      expect(gateway.calls, 1);
    });

    test('failing leaves it locked, and it can be retried', () async {
      final c = container(enabled: true);
      gateway.next = AuthOutcome.failed;
      await lock(c).unlock();
      expect(stateOf(c).locked, isTrue);

      gateway.next = AuthOutcome.success;
      await lock(c).unlock();
      expect(stateOf(c).locked, isFalse);
    });

    test('removing the screen lock can never lock you out', () async {
      await db.writeSetting(biometricLockSettingKey, 'true');
      final c = container(enabled: true);
      gateway.next = AuthOutcome.unavailable;

      await lock(c).unlock();

      expect(stateOf(c).locked, isFalse);
      expect(stateOf(c).enabled, isFalse);
      expect(await db.readSetting(biometricLockSettingKey), isNull);
    });
  });

  testWidgets('hides the app while locked, then reveals it', (tester) async {
    final c = container(enabled: true);
    gateway.next = AuthOutcome.failed;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const AppLockGate(child: Text('private content')),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('WorkPulse is locked'), findsOneWidget);
    expect(find.text('private content'), findsNothing);
    expect(gateway.calls, 1);

    gateway.next = AuthOutcome.success;
    await tester.tap(find.text('Unlock'));
    await tester.pump();
    await tester.pump();

    expect(find.text('WorkPulse is locked'), findsNothing);
    expect(find.text('private content'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
