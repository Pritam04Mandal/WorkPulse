import '../../../core/domain/enums.dart';
import 'auth_models.dart';

/// One external sign-in provider.
abstract interface class IdentityProvider {
  bool get isConfigured;

  /// Runs the interactive flow. Throws [AuthFailure].
  Future<ProviderIdentity> signIn();

  /// Restores a session without UI, or returns null if that isn't possible.
  Future<ProviderIdentity?> restore();

  Future<void> signOut();
}

abstract interface class TokenStore {
  Future<void> saveIdToken(AuthProvider provider, String? token);
  Future<void> clear(AuthProvider provider);
}

abstract interface class AuthRepository {
  Future<UserProfile?> currentUser();

  /// Throws [AuthFailure].
  Future<UserProfile> signIn(AuthProvider provider);

  /// Returns the existing local profile, or creates one.
  Future<UserProfile> continueWithoutAccount();

  /// Silently refreshes the signed-in user's profile and token, if possible.
  Future<UserProfile?> restoreSession();

  /// Ends the session. The profile row and all activity stay on the device.
  Future<void> signOut();

  /// Signs out of every provider, then empties the local database.
  Future<void> deleteAllLocalData();
}
