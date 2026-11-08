import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/setting_keys.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/presentation/session_controller.dart';
import '../data/biometric_gateway.dart';

/// Coming back within this long doesn't ask again, so quickly checking
/// another app or approving something in a browser isn't a chore.
const lockGracePeriod = Duration(seconds: 30);

/// Overridden in `main` with the saved setting, so the very first frame is
/// already locked and nothing shows before the prompt.
final initialLockEnabledProvider = Provider<bool>((ref) => false);

final lockClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

enum LockChangeResult { changed, cancelled, unavailable }

class AppLockState {
  const AppLockState({
    this.enabled = false,
    this.locked = false,
    this.authenticating = false,
  });

  final bool enabled;
  final bool locked;
  final bool authenticating;

  AppLockState copyWith({bool? enabled, bool? locked, bool? authenticating}) =>
      AppLockState(
        enabled: enabled ?? this.enabled,
        locked: locked ?? this.locked,
        authenticating: authenticating ?? this.authenticating,
      );
}

final appLockProvider = NotifierProvider<AppLockController, AppLockState>(
  AppLockController.new,
);

class AppLockController extends Notifier<AppLockState> {
  DateTime? _hiddenAt;

  BiometricGateway get _gateway => ref.read(biometricGatewayProvider);

  bool get _onboarded => ref.read(sessionProvider).onboardingComplete;

  @override
  AppLockState build() {
    ref.listen(sessionProvider.select((s) => s.onboardingComplete), (_, done) {
      if (!done) _reloadAfterReset();
    });
    final enabled = ref.watch(initialLockEnabledProvider);
    return AppLockState(enabled: enabled, locked: enabled && _onboarded);
  }

  /// Sign-out and Delete all data return to Welcome, which is never locked.
  Future<void> _reloadAfterReset() async {
    final saved = await ref
        .read(databaseProvider)
        .readSetting(biometricLockSettingKey);
    if (ref.mounted) state = AppLockState(enabled: saved == 'true');
  }

  void onHidden() {
    // The system prompt can hide the app for a moment. That isn't leaving.
    if (!state.authenticating) _hiddenAt = ref.read(lockClockProvider)();
  }

  Future<void> onResumed() async {
    final hiddenAt = _hiddenAt;
    _hiddenAt = null;
    if (!state.enabled || !_onboarded || hiddenAt == null) return;
    if (state.authenticating) return;
    final away = ref.read(lockClockProvider)().difference(hiddenAt);
    if (away >= lockGracePeriod) {
      state = state.copyWith(locked: true);
      await unlock();
    }
  }

  Future<void> unlock() async {
    if (state.authenticating || !state.locked) return;
    state = state.copyWith(authenticating: true);
    final outcome = await _gateway.authenticate('Unlock WorkPulse');
    if (!ref.mounted) return;
    switch (outcome) {
      case AuthOutcome.success:
        state = state.copyWith(locked: false, authenticating: false);
      case AuthOutcome.failed:
        state = state.copyWith(authenticating: false);
      case AuthOutcome.unavailable:
        // The screen lock was removed. Staying locked would mean losing
        // access to everything, so the app lock turns itself off.
        await ref.read(databaseProvider).deleteSetting(biometricLockSettingKey);
        if (ref.mounted) state = const AppLockState();
    }
  }

  /// Asks first in both directions, so nobody holding the unlocked phone can
  /// switch this off, or turn it on and shut the owner out.
  Future<LockChangeResult> setEnabled(bool enabled) async {
    if (state.authenticating) return LockChangeResult.cancelled;
    state = state.copyWith(authenticating: true);
    final outcome = await _gateway.authenticate(
      enabled ? 'Turn on app lock' : 'Turn off app lock',
    );
    if (!ref.mounted) return LockChangeResult.cancelled;
    if (outcome != AuthOutcome.success) {
      state = state.copyWith(authenticating: false);
      return outcome == AuthOutcome.unavailable
          ? LockChangeResult.unavailable
          : LockChangeResult.cancelled;
    }
    final database = ref.read(databaseProvider);
    if (enabled) {
      await database.writeSetting(biometricLockSettingKey, 'true');
    } else {
      await database.deleteSetting(biometricLockSettingKey);
    }
    if (ref.mounted) {
      state = state.copyWith(enabled: enabled, authenticating: false);
    }
    return LockChangeResult.changed;
  }
}

/// Keeps the app's screens alive but off-screen while locked.
class AppLockGate extends ConsumerWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locked = ref.watch(appLockProvider.select((s) => s.locked));
    return Stack(
      fit: StackFit.expand,
      children: [
        Offstage(offstage: locked, child: child),
        if (locked) const LockScreen(),
      ],
    );
  }
}

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(appLockProvider.notifier).unlock();
    });
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(appLockProvider.select((s) => s.authenticating));
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: PulseMark(size: 48)),
              const SizedBox(height: 20),
              Text(
                'WorkPulse is locked',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Use your fingerprint, face or screen lock to continue.',
                textAlign: TextAlign.center,
                style: AppText.caption,
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: busy
                    ? null
                    : () => ref.read(appLockProvider.notifier).unlock(),
                child: const Text('Unlock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
