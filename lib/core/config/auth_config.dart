/// OAuth client configuration, supplied at build time with `--dart-define`.
/// Unset values leave that provider showing a "not configured" state.
class AuthConfig {
  const AuthConfig({
    this.googleServerClientId = const String.fromEnvironment(
      'GOOGLE_SERVER_CLIENT_ID',
    ),
    this.msalClientId = const String.fromEnvironment('MSAL_CLIENT_ID'),
    this.msalRedirectUri = const String.fromEnvironment('MSAL_REDIRECT_URI'),
    this.githubClientId = const String.fromEnvironment('GITHUB_CLIENT_ID'),
  });

  /// The Web client ID from Google Cloud, needed for an Android ID token.
  final String googleServerClientId;
  final String msalClientId;

  /// `msauth://<package>/<url-encoded signature hash>`.
  final String msalRedirectUri;

  /// From a GitHub OAuth App with Device Flow enabled. Not a secret.
  final String githubClientId;

  bool get isGoogleConfigured => googleServerClientId.isNotEmpty;
  bool get isMicrosoftConfigured =>
      msalClientId.isNotEmpty && msalRedirectUri.isNotEmpty;
}
