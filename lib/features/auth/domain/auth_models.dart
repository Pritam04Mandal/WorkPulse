import '../../../core/domain/enums.dart';

enum AuthFailureKind { cancelled, unavailable, expired, notConfigured }

/// A sign-in failure. Carries no provider detail, so it is always safe to log.
class AuthFailure implements Exception {
  const AuthFailure(this.kind);

  final AuthFailureKind kind;

  @override
  String toString() => 'AuthFailure(${kind.name})';
}

/// What a provider returns after authenticating the user.
class ProviderIdentity {
  const ProviderIdentity({
    required this.subjectId,
    this.name,
    this.email,
    this.photoUrl,
    this.idToken,
  });

  final String subjectId;
  final String? name;
  final String? email;
  final String? photoUrl;
  final String? idToken;

  @override
  String toString() => 'ProviderIdentity(<redacted>)';
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.provider,
    required this.createdAt,
    required this.lastLoginAt,
    this.subjectId,
    this.name,
    this.email,
    this.photoUrl,
  });

  final String id;
  final AuthProvider provider;
  final String? subjectId;
  final String? name;
  final String? email;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  bool get isLocal => provider == AuthProvider.local;
}
