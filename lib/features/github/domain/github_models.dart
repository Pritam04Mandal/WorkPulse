import '../../../core/domain/enums.dart';

class DeviceCode {
  const DeviceCode({
    required this.deviceCode,
    required this.userCode,
    required this.verificationUri,
    required this.expiresIn,
    required this.interval,
  });

  final String deviceCode;
  final String userCode;
  final String verificationUri;
  final Duration expiresIn;
  final Duration interval;

  @override
  String toString() => 'DeviceCode(<redacted>)';
}

sealed class PollResult {
  const PollResult();
}

class PollPending extends PollResult {
  const PollPending();
}

class PollSlowDown extends PollResult {
  const PollSlowDown();
}

class PollToken extends PollResult {
  const PollToken(this.token, this.scopes);

  final String token;
  final String scopes;

  @override
  String toString() => 'PollToken(<redacted>)';
}

enum GitHubFailureKind { expired, denied, revoked, unavailable, notConfigured }

/// Carries no response detail, so it is always safe to log.
class GitHubFailure implements Exception {
  const GitHubFailure(this.kind);

  final GitHubFailureKind kind;

  @override
  String toString() => 'GitHubFailure(${kind.name})';
}

class GitHubActivity {
  const GitHubActivity({
    required this.externalId,
    required this.kind,
    required this.title,
    required this.repository,
    required this.occurredAt,
  });

  final String externalId;
  final ActivityKind kind;
  final String title;

  /// `owner/name`.
  final String repository;
  final DateTime occurredAt;
}

class PushedRepository {
  const PushedRepository(this.fullName, this.pushedAt);

  final String fullName;
  final DateTime pushedAt;
}

class PushedRepositories {
  const PushedRepositories(this.etag, this.repositories);

  final String? etag;
  final List<PushedRepository> repositories;
}

class RateBudget {
  const RateBudget(this.remaining, this.limit);

  final int remaining;
  final int limit;
}

/// The connection as the screens see it.
class GitHubStatus {
  const GitHubStatus({
    required this.login,
    required this.connected,
    required this.needsReconnect,
    required this.eventCount,
    required this.trackedRepositories,
    required this.ignoredRepositories,
    this.scopes,
    this.lastSyncedAt,
  });

  final String login;
  final bool connected;

  /// GitHub rejected the saved token, for example after it was revoked.
  final bool needsReconnect;
  final int eventCount;
  final int trackedRepositories;
  final int ignoredRepositories;
  final String? scopes;
  final DateTime? lastSyncedAt;
}
