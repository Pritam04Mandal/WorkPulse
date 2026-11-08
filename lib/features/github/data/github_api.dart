import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/domain/enums.dart';
import '../domain/github_models.dart';

const _scopes = 'read:user repo';

const _contributionsQuery = r'''
query($from: DateTime!, $to: DateTime!) {
  viewer {
    contributionsCollection(from: $from, to: $to) {
      pullRequestContributions(first: 100) {
        nodes {
          occurredAt
          pullRequest { id number title repository { nameWithOwner } }
        }
      }
      pullRequestReviewContributions(first: 100) {
        nodes {
          occurredAt
          pullRequestReview { id }
          pullRequest { number title repository { nameWithOwner } }
        }
      }
      issueContributions(first: 100) {
        nodes {
          occurredAt
          issue { id number title repository { nameWithOwner } }
        }
      }
    }
  }
}
''';

abstract interface class GitHubClient {
  Future<DeviceCode> requestDeviceCode();
  Future<PollResult> pollForToken(String deviceCode);
  Future<String> fetchLogin(String token);
  Future<List<String>> fetchRepositories(String token);
  Future<List<GitHubActivity>> fetchActivity(
    String token, {
    required String login,
    required DateTime since,
    required DateTime until,
  });
  Future<RateBudget> fetchRateBudget(String token);

  /// The most recently pushed repositories, or null if nothing changed since
  /// [etag]. An unchanged answer doesn't count against the rate limit.
  Future<PushedRepositories?> fetchPushedRepositories(
    String token, {
    String? etag,
  });

  /// The user's commits pushed to [repository] since [since], on any branch.
  Future<List<GitHubActivity>> fetchRecentCommits(
    String token, {
    required String repository,
    required String login,
    required DateTime since,
  });
}

/// Talks to github.com. Reads only: nothing here can write to GitHub.
class GitHubApi implements GitHubClient {
  GitHubApi(this._http, this._clientId);

  final http.Client _http;
  final String _clientId;

  static final _commitSearchPages = [1, 2, 3];
  static const _maxBranches = 5;

  Map<String, String> _headers(String token) => {
    'Accept': 'application/vnd.github+json',
    'Authorization': 'Bearer $token',
    'X-GitHub-Api-Version': '2022-11-28',
  };

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request();
    } on Exception {
      throw const GitHubFailure(GitHubFailureKind.unavailable);
    }
  }

  Object? _decode(http.Response response) {
    if (response.statusCode == 401) {
      throw const GitHubFailure(GitHubFailureKind.revoked);
    }
    if (response.statusCode >= 400) {
      throw const GitHubFailure(GitHubFailureKind.unavailable);
    }
    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw const GitHubFailure(GitHubFailureKind.unavailable);
    }
  }

  @override
  Future<DeviceCode> requestDeviceCode() async {
    if (_clientId.isEmpty) {
      throw const GitHubFailure(GitHubFailureKind.notConfigured);
    }
    final response = await _send(
      () => _http.post(
        Uri.https('github.com', '/login/device/code'),
        headers: const {'Accept': 'application/json'},
        body: {'client_id': _clientId, 'scope': _scopes},
      ),
    );
    final body = _decode(response)! as Map<String, Object?>;
    if (body['device_code'] == null) {
      throw GitHubFailure(
        body['error'] == 'device_flow_disabled' ||
                body['error'] == 'incorrect_client_credentials'
            ? GitHubFailureKind.notConfigured
            : GitHubFailureKind.unavailable,
      );
    }
    return DeviceCode(
      deviceCode: body['device_code']! as String,
      userCode: body['user_code']! as String,
      verificationUri: body['verification_uri']! as String,
      expiresIn: Duration(seconds: body['expires_in']! as int),
      interval: Duration(seconds: body['interval']! as int),
    );
  }

  @override
  Future<PollResult> pollForToken(String deviceCode) async {
    final response = await _send(
      () => _http.post(
        Uri.https('github.com', '/login/oauth/access_token'),
        headers: const {'Accept': 'application/json'},
        body: {
          'client_id': _clientId,
          'device_code': deviceCode,
          'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
        },
      ),
    );
    final body = _decode(response)! as Map<String, Object?>;
    final token = body['access_token'] as String?;
    if (token != null) return PollToken(token, body['scope'] as String? ?? '');
    return switch (body['error']) {
      'authorization_pending' => const PollPending(),
      'slow_down' => const PollSlowDown(),
      'expired_token' => throw const GitHubFailure(GitHubFailureKind.expired),
      'access_denied' => throw const GitHubFailure(GitHubFailureKind.denied),
      _ => throw const GitHubFailure(GitHubFailureKind.unavailable),
    };
  }

  @override
  Future<String> fetchLogin(String token) async {
    final response = await _send(
      () => _http.get(
        Uri.https('api.github.com', '/user'),
        headers: _headers(token),
      ),
    );
    return (_decode(response)! as Map<String, Object?>)['login']! as String;
  }

  @override
  Future<List<String>> fetchRepositories(String token) async {
    final response = await _send(
      () => _http.get(
        Uri.https('api.github.com', '/user/repos', {
          'per_page': '100',
          'sort': 'pushed',
        }),
        headers: _headers(token),
      ),
    );
    return [
      for (final repo in _decode(response)! as List<Object?>)
        (repo! as Map<String, Object?>)['full_name']! as String,
    ];
  }

  @override
  Future<List<GitHubActivity>> fetchActivity(
    String token, {
    required String login,
    required DateTime since,
    required DateTime until,
  }) async {
    final results = await Future.wait([
      _fetchCommits(token, login, since),
      _fetchContributions(token, since, until),
    ]);
    return [for (final part in results) ...part];
  }

  /// GitHub only indexes each repository's default branch for commit search,
  /// so branch work appears once it is merged.
  Future<List<GitHubActivity>> _fetchCommits(
    String token,
    String login,
    DateTime since,
  ) async {
    final commits = <GitHubActivity>[];
    final from = since.toUtc().toIso8601String().split('.').first;
    for (final page in _commitSearchPages) {
      final response = await _send(
        () => _http.get(
          Uri.https('api.github.com', '/search/commits', {
            'q': 'author:$login author-date:>=${from}Z',
            'sort': 'author-date',
            'order': 'desc',
            'per_page': '100',
            'page': '$page',
          }),
          headers: _headers(token),
        ),
      );
      final items =
          (_decode(response)! as Map<String, Object?>)['items']!
              as List<Object?>;
      for (final raw in items) {
        final item = raw! as Map<String, Object?>;
        final commit = item['commit']! as Map<String, Object?>;
        final message = (commit['message']! as String).split('\n').first;
        final author = commit['author']! as Map<String, Object?>;
        final repository = item['repository']! as Map<String, Object?>;
        commits.add(
          GitHubActivity(
            externalId: 'commit:${item['sha']}',
            kind: ActivityKind.commit,
            title: 'Commit · $message',
            repository: repository['full_name']! as String,
            occurredAt: DateTime.parse(author['date']! as String).toLocal(),
          ),
        );
      }
      if (items.length < 100) break;
    }
    return commits;
  }

  Future<List<GitHubActivity>> _fetchContributions(
    String token,
    DateTime since,
    DateTime until,
  ) async {
    final response = await _send(
      () => _http.post(
        Uri.https('api.github.com', '/graphql'),
        headers: {..._headers(token), 'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': _contributionsQuery,
          'variables': {
            'from': since.toUtc().toIso8601String(),
            'to': until.toUtc().toIso8601String(),
          },
        }),
      ),
    );
    final body = _decode(response)! as Map<String, Object?>;
    final data = body['data'] as Map<String, Object?>?;
    final viewer = data?['viewer'] as Map<String, Object?>?;
    final collection =
        viewer?['contributionsCollection'] as Map<String, Object?>?;
    if (collection == null) {
      throw const GitHubFailure(GitHubFailureKind.unavailable);
    }

    Iterable<Map<String, Object?>> nodes(String field) =>
        ((collection[field]! as Map<String, Object?>)['nodes']!
                as List<Object?>)
            .whereType<Map<String, Object?>>();
    DateTime time(Map<String, Object?> node) =>
        DateTime.parse(node['occurredAt']! as String).toLocal();
    String repo(Map<String, Object?> item) =>
        (item['repository']! as Map<String, Object?>)['nameWithOwner']!
            as String;

    return [
      for (final node in nodes('pullRequestContributions'))
        if (node['pullRequest'] case final Map<String, Object?> pr)
          GitHubActivity(
            externalId: 'pr:${pr['id']}',
            kind: ActivityKind.pullRequest,
            title: 'Opened PR #${pr['number']} · ${pr['title']}',
            repository: repo(pr),
            occurredAt: time(node),
          ),
      for (final node in nodes('pullRequestReviewContributions'))
        if (node['pullRequest'] case final Map<String, Object?> pr)
          GitHubActivity(
            externalId:
                'review:${(node['pullRequestReview']! as Map<String, Object?>)['id']}',
            kind: ActivityKind.review,
            title: 'Reviewed PR #${pr['number']} · ${pr['title']}',
            repository: repo(pr),
            occurredAt: time(node),
          ),
      for (final node in nodes('issueContributions'))
        if (node['issue'] case final Map<String, Object?> issue)
          GitHubActivity(
            externalId: 'issue:${issue['id']}',
            kind: ActivityKind.issue,
            title: 'Opened issue #${issue['number']} · ${issue['title']}',
            repository: repo(issue),
            occurredAt: time(node),
          ),
    ];
  }

  @override
  Future<PushedRepositories?> fetchPushedRepositories(
    String token, {
    String? etag,
  }) async {
    final response = await _send(
      () => _http.get(
        Uri.https('api.github.com', '/user/repos', {
          'per_page': '30',
          'sort': 'pushed',
        }),
        headers: {..._headers(token), 'If-None-Match': ?etag},
      ),
    );
    if (response.statusCode == 304) return null;
    return PushedRepositories(response.headers['etag'], [
      for (final raw in _decode(response)! as List<Object?>)
        if ((raw! as Map<String, Object?>)['pushed_at']
            case final String pushedAt)
          PushedRepository(
            (raw as Map<String, Object?>)['full_name']! as String,
            DateTime.parse(pushedAt).toLocal(),
          ),
    ]);
  }

  @override
  Future<List<GitHubActivity>> fetchRecentCommits(
    String token, {
    required String repository,
    required String login,
    required DateTime since,
  }) async {
    final commits = <String, GitHubActivity>{};
    for (final branch in await _pushedBranches(
      token,
      repository,
      login,
      since,
    )) {
      final response = await _send(
        () => _http.get(
          Uri.https('api.github.com', '/repos/$repository/commits', {
            'author': login,
            'since': since.toUtc().toIso8601String(),
            'per_page': '100',
            'sha': ?branch,
          }),
          headers: _headers(token),
        ),
      );
      for (final raw in _decode(response)! as List<Object?>) {
        final item = raw! as Map<String, Object?>;
        final commit = item['commit']! as Map<String, Object?>;
        final author = commit['author']! as Map<String, Object?>;
        final sha = item['sha']! as String;
        commits[sha] = GitHubActivity(
          externalId: 'commit:$sha',
          kind: ActivityKind.commit,
          title: 'Commit · ${(commit['message']! as String).split('\n').first}',
          repository: repository,
          occurredAt: DateTime.parse(author['date']! as String).toLocal(),
        );
      }
    }
    return commits.values.toList();
  }

  /// Branches the user just pushed to. A null entry means the default branch,
  /// used when GitHub won't share the repository's activity.
  Future<List<String?>> _pushedBranches(
    String token,
    String repository,
    String login,
    DateTime since,
  ) async {
    const prefix = 'refs/heads/';
    try {
      final response = await _send(
        () => _http.get(
          Uri.https('api.github.com', '/repos/$repository/activity', {
            'actor': login,
            'activity_type': 'push',
            'time_period': 'day',
            'per_page': '30',
          }),
          headers: _headers(token),
        ),
      );
      final branches = <String>{
        for (final raw in _decode(response)! as List<Object?>)
          if (raw! as Map<String, Object?>
              case {
                'ref': final String ref,
                'timestamp': final String timestamp,
              }
              when ref.startsWith(prefix) &&
                  !DateTime.parse(timestamp).isBefore(since))
            ref.substring(prefix.length),
      };
      return branches.isEmpty
          ? const [null]
          : branches.take(_maxBranches).toList();
    } on GitHubFailure catch (failure) {
      if (failure.kind == GitHubFailureKind.revoked) rethrow;
      return const [null];
    }
  }

  @override
  Future<RateBudget> fetchRateBudget(String token) async {
    final response = await _send(
      () => _http.get(
        Uri.https('api.github.com', '/rate_limit'),
        headers: _headers(token),
      ),
    );
    final body = _decode(response)! as Map<String, Object?>;
    final resources = body['resources']! as Map<String, Object?>;
    final core = resources['core']! as Map<String, Object?>;
    return RateBudget(core['remaining']! as int, core['limit']! as int);
  }
}
