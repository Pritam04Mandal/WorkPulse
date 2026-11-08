import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/config/auth_config.dart';
import '../domain/auth_contracts.dart';
import '../domain/auth_models.dart';

class GoogleIdentityProvider implements IdentityProvider {
  GoogleIdentityProvider(this._config);

  final AuthConfig _config;
  Future<void>? _initialized;

  GoogleSignIn get _client => GoogleSignIn.instance;

  Future<void> _ensureInitialized() => _initialized ??= _client.initialize(
    serverClientId: _config.googleServerClientId,
  );

  @override
  bool get isConfigured => _config.isGoogleConfigured;

  @override
  Future<ProviderIdentity> signIn() async {
    if (!isConfigured) throw const AuthFailure(AuthFailureKind.notConfigured);
    try {
      await _ensureInitialized();
      if (!_client.supportsAuthenticate()) {
        throw const AuthFailure(AuthFailureKind.unavailable);
      }
      return _toIdentity(await _client.authenticate());
    } on GoogleSignInException catch (e) {
      throw AuthFailure(_failureKind(e.code));
    }
  }

  @override
  Future<ProviderIdentity?> restore() async {
    if (!isConfigured) return null;
    try {
      await _ensureInitialized();
      final account = await _client.attemptLightweightAuthentication();
      return account == null ? null : _toIdentity(account);
    } on GoogleSignInException {
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    if (!isConfigured) return;
    await _ensureInitialized();
    await _client.signOut();
  }

  ProviderIdentity _toIdentity(GoogleSignInAccount account) => ProviderIdentity(
    subjectId: account.id,
    name: account.displayName,
    email: account.email,
    photoUrl: account.photoUrl,
    idToken: account.authentication.idToken,
  );

  AuthFailureKind _failureKind(GoogleSignInExceptionCode code) =>
      switch (code) {
        GoogleSignInExceptionCode.canceled => AuthFailureKind.cancelled,
        GoogleSignInExceptionCode.clientConfigurationError ||
        GoogleSignInExceptionCode.providerConfigurationError =>
          AuthFailureKind.notConfigured,
        _ => AuthFailureKind.unavailable,
      };
}
