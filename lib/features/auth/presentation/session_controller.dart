import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/domain/enums.dart';
import '../domain/auth_contracts.dart';
import '../domain/auth_models.dart';

const onboardingCompleteSettingKey = 'onboarding_complete';

/// Overridden in `main` with the opened database.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

/// Overridden in `main` with the on-device repository.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) =>
      throw UnimplementedError('authRepositoryProvider must be overridden'),
);

class Session {
  const Session({this.user, this.onboardingComplete = false});

  final UserProfile? user;
  final bool onboardingComplete;

  Session copyWith({UserProfile? user, bool? onboardingComplete}) => Session(
    user: user ?? this.user,
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
  );
}

/// Overridden in `main` with the session read at startup, so the first route
/// is correct without a loading screen.
final initialSessionProvider = Provider<Session>((ref) => const Session());

Future<Session> loadSession(AppDatabase db, AuthRepository repository) async =>
    Session(
      user: await repository.currentUser(),
      onboardingComplete:
          await db.readSetting(onboardingCompleteSettingKey) == 'true',
    );

final sessionProvider = NotifierProvider<SessionController, Session>(
  SessionController.new,
);

class SessionController extends Notifier<Session> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  Session build() => ref.watch(initialSessionProvider);

  /// Throws [AuthFailure].
  Future<UserProfile> signIn(AuthProvider provider) async {
    final user = await _repository.signIn(provider);
    state = state.copyWith(user: user);
    return user;
  }

  Future<void> continueWithoutAccount() async {
    final user = await _repository.continueWithoutAccount();
    state = state.copyWith(user: user);
  }

  /// Best effort: a failed refresh leaves the saved profile in place.
  Future<void> restore() async {
    final user = await _repository.restoreSession();
    if (user != null) state = state.copyWith(user: user);
  }

  /// Ends the session and returns to Welcome. Activity stays on the device.
  Future<void> signOut() async {
    await _repository.signOut();
    await ref
        .read(databaseProvider)
        .deleteSetting(onboardingCompleteSettingKey);
    state = const Session();
  }

  /// Wipes the device. Leaves [state] alone so the confirmation can show;
  /// call [startOver] afterwards.
  Future<void> deleteAllData() => _repository.deleteAllLocalData();

  void startOver() => state = const Session();

  Future<void> completeOnboarding() async {
    // Reaching the app always leaves a profile behind, even after "Not now".
    if (state.user == null) await continueWithoutAccount();
    await ref
        .read(databaseProvider)
        .writeSetting(onboardingCompleteSettingKey, 'true');
    state = state.copyWith(onboardingComplete: true);
  }
}
