import 'package:msal_auth/msal_auth.dart';

import '../../../core/config/auth_config.dart';
import '../domain/auth_contracts.dart';
import '../domain/auth_models.dart';

class MicrosoftIdentityProvider implements IdentityProvider {
  MicrosoftIdentityProvider(this._config);

  // Identity only. Calendar access is requested separately by the Teams flow.
  static const _scopes = ['openid', 'profile', 'email'];

  final AuthConfig _config;
  SingleAccountPca? _pca;

  Future<SingleAccountPca> _client() async =>
      _pca ??= await SingleAccountPca.create(
        clientId: _config.msalClientId,
        androidConfig: AndroidConfig(
          configFilePath: 'assets/msal_config.json',
          redirectUri: _config.msalRedirectUri,
        ),
      );

  @override
  bool get isConfigured => _config.isMicrosoftConfigured;

  @override
  Future<ProviderIdentity> signIn() async {
    if (!isConfigured) throw const AuthFailure(AuthFailureKind.notConfigured);
    try {
      final client = await _client();
      final result = await client.acquireToken(
        scopes: _scopes,
        prompt: Prompt.selectAccount,
      );
      return _toIdentity(result);
    } on MsalUserCancelException {
      throw const AuthFailure(AuthFailureKind.cancelled);
    } on MsalUiRequiredException {
      throw const AuthFailure(AuthFailureKind.expired);
    } on MsalNoCurrentAccountException {
      throw const AuthFailure(AuthFailureKind.expired);
    } on MsalException {
      throw const AuthFailure(AuthFailureKind.unavailable);
    }
  }

  @override
  Future<ProviderIdentity?> restore() async {
    if (!isConfigured) return null;
    try {
      final client = await _client();
      return _toIdentity(await client.acquireTokenSilent(scopes: _scopes));
    } on MsalException {
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    if (!isConfigured) return;
    try {
      final client = await _client();
      await client.signOut();
    } on MsalNoCurrentAccountException {
      // Already signed out.
    }
  }

  ProviderIdentity _toIdentity(AuthenticationResult result) => ProviderIdentity(
    subjectId: result.account.id,
    name: result.account.name,
    email: result.account.username,
    idToken: result.idToken,
  );
}
