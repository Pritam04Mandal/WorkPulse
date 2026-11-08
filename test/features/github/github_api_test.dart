import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:workpulse/core/domain/enums.dart';
import 'package:workpulse/features/github/data/github_api.dart';
import 'package:workpulse/features/github/domain/github_models.dart';

http.Response json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status);

GitHubApi api(
  http.Response Function(http.Request) handler, {
  String id = 'x',
}) => GitHubApi(MockClient((request) async => handler(request)), id);

Matcher failsWith(GitHubFailureKind kind) =>
    throwsA(isA<GitHubFailure>().having((f) => f.kind, 'kind', kind));

void main() {
  test('requests a device code with read-only scopes', () async {
    late http.Request sent;
    final code = await api((request) {
      sent = request;
      return json({
        'device_code': 'dev',
        'user_code': 'ABCD-1234',
        'verification_uri': 'https://github.com/login/device',
        'expires_in': 899,
        'interval': 5,
      });
    }).requestDeviceCode();

    expect(sent.url.path, '/login/device/code');
    expect(sent.bodyFields['scope'], 'read:user repo');
    expect(code.userCode, 'ABCD-1234');
    expect(code.interval, const Duration(seconds: 5));
    expect(code.toString(), isNot(contains('dev')));
  });

  test('no client ID reports not configured without a request', () async {
    var called = false;
    final client = api((request) {
      called = true;
      return json({});
    }, id: '');

    await expectLater(
      client.requestDeviceCode(),
      failsWith(GitHubFailureKind.notConfigured),
    );
    expect(called, isFalse);
  });

  test('Device Flow turned off reports not configured', () async {
    await expectLater(
      api((_) => json({'error': 'device_flow_disabled'})).requestDeviceCode(),
      failsWith(GitHubFailureKind.notConfigured),
    );
  });

  group('polling', () {
    Future<PollResult> poll(Map<String, Object> body) =>
        api((_) => json(body)).pollForToken('dev');

    test('pending and slow down keep waiting', () async {
      expect(
        await poll({'error': 'authorization_pending'}),
        isA<PollPending>(),
      );
      expect(await poll({'error': 'slow_down'}), isA<PollSlowDown>());
    });

    test('returns the token and scopes', () async {
      final result = await poll({
        'access_token': 'secret-token',
        'scope': 'repo,read:user',
      });
      expect(result, isA<PollToken>());
      expect((result as PollToken).scopes, 'repo,read:user');
      expect(result.toString(), isNot(contains('secret-token')));
    });

    test('expired and denied are terminal', () async {
      await expectLater(
        poll({'error': 'expired_token'}),
        failsWith(GitHubFailureKind.expired),
      );
      await expectLater(
        poll({'error': 'access_denied'}),
        failsWith(GitHubFailureKind.denied),
      );
    });
  });

  test('a 401 means the token was revoked', () async {
    await expectLater(
      api((_) => json({}, 401)).fetchLogin('t'),
      failsWith(GitHubFailureKind.revoked),
    );
  });

  test('a network failure never leaks the exception', () async {
    final client = GitHubApi(
      MockClient((_) async => throw http.ClientException('with token t')),
      'x',
    );
    await expectLater(
      client.fetchLogin('t'),
      failsWith(GitHubFailureKind.unavailable),
    );
  });

  test('parses commits, PRs, reviews and issues', () async {
    Map<String, Object> repo() => {'nameWithOwner': 'me/app'};
    final activity =
        await api((request) {
          if (request.url.path == '/search/commits') {
            expect(request.headers['Authorization'], 'Bearer t');
            expect(request.url.queryParameters['q'], startsWith('author:me '));
            return json({
              'items': [
                {
                  'sha': 'abc',
                  'commit': {
                    'message': 'Add drift migrations\n\nLonger body',
                    'author': {'date': '2026-11-08T10:00:00Z'},
                  },
                  'repository': {'full_name': 'me/app'},
                },
              ],
            });
          }
          return json({
            'data': {
              'viewer': {
                'contributionsCollection': {
                  'pullRequestContributions': {
                    'nodes': [
                      {
                        'occurredAt': '2026-11-08T11:00:00Z',
                        'pullRequest': {
                          'id': 'P1',
                          'number': 42,
                          'title': 'Migrations',
                          'repository': repo(),
                        },
                      },
                    ],
                  },
                  'pullRequestReviewContributions': {
                    'nodes': [
                      {
                        'occurredAt': '2026-11-08T12:00:00Z',
                        'pullRequestReview': {'id': 'R1'},
                        'pullRequest': {
                          'number': 17,
                          'title': 'Billing',
                          'repository': repo(),
                        },
                      },
                    ],
                  },
                  'issueContributions': {
                    'nodes': [
                      {
                        'occurredAt': '2026-11-08T13:00:00Z',
                        'issue': {
                          'id': 'I1',
                          'number': 3,
                          'title': 'Bug',
                          'repository': repo(),
                        },
                      },
                    ],
                  },
                },
              },
            },
          });
        }).fetchActivity(
          't',
          login: 'me',
          since: DateTime.utc(2026, 11, 1),
          until: DateTime.utc(2026, 11, 9),
        );

    expect(activity.map((a) => a.kind), [
      ActivityKind.commit,
      ActivityKind.pullRequest,
      ActivityKind.review,
      ActivityKind.issue,
    ]);
    expect(activity[0].title, 'Commit · Add drift migrations');
    expect(activity[0].externalId, 'commit:abc');
    expect(activity[1].title, 'Opened PR #42 · Migrations');
    expect(activity[2].title, 'Reviewed PR #17 · Billing');
    expect(activity[3].repository, 'me/app');
  });

  test('an unchanged repository list returns null', () async {
    late http.Request sent;
    final result = await api((request) {
      sent = request;
      return http.Response('', 304);
    }).fetchPushedRepositories('t', etag: 'abc');

    expect(result, isNull);
    expect(sent.headers['If-None-Match'], 'abc');
  });

  test('reads pushed repositories and skips ones never pushed', () async {
    final result = await api(
      (_) => http.Response(
        jsonEncode([
          {'full_name': 'me/app', 'pushed_at': '2026-11-08T10:00:00Z'},
          {'full_name': 'me/empty', 'pushed_at': null},
        ]),
        200,
        headers: {'etag': 'W/"x"'},
      ),
    ).fetchPushedRepositories('t');

    expect(result?.etag, 'W/"x"');
    expect(result?.repositories.single.fullName, 'me/app');
  });

  group('recent commits', () {
    Map<String, Object> commitJson(String sha) => {
      'sha': sha,
      'commit': {
        'message': 'Change $sha\n\nBody',
        'author': {'date': '2026-11-08T10:00:00Z'},
      },
    };
    final since = DateTime.utc(2026, 11, 8);

    test('reads each pushed branch and removes duplicates', () async {
      final branches = <String?>[];
      final commits =
          await api((request) {
            if (request.url.path.endsWith('/activity')) {
              return json([
                {'ref': 'refs/heads/main', 'timestamp': '2026-11-08T10:00:00Z'},
                {
                  'ref': 'refs/heads/feat/x',
                  'timestamp': '2026-11-08T11:00:00Z',
                },
                {'ref': 'refs/heads/old', 'timestamp': '2026-11-01T10:00:00Z'},
                {'ref': 'refs/tags/v1', 'timestamp': '2026-11-08T11:00:00Z'},
              ]);
            }
            branches.add(request.url.queryParameters['sha']);
            return json([commitJson('shared')]);
          }).fetchRecentCommits(
            't',
            repository: 'me/app',
            login: 'me',
            since: since,
          );

      expect(branches, ['main', 'feat/x']);
      expect(commits.single.title, 'Commit · Change shared');
    });

    test('falls back to the default branch without activity access', () async {
      final branches = <String?>[];
      await api((request) {
        if (request.url.path.endsWith('/activity')) return json({}, 403);
        branches.add(request.url.queryParameters['sha']);
        return json([commitJson('a')]);
      }).fetchRecentCommits(
        't',
        repository: 'me/app',
        login: 'me',
        since: since,
      );
      expect(branches, [null]);
    });

    test('a rejected token is not hidden by the fallback', () async {
      await expectLater(
        api((_) => json({}, 401)).fetchRecentCommits(
          't',
          repository: 'me/app',
          login: 'me',
          since: since,
        ),
        failsWith(GitHubFailureKind.revoked),
      );
    });
  });

  test('a GraphQL error response is a failure, not an empty result', () async {
    await expectLater(
      api((request) {
        if (request.url.path == '/search/commits') return json({'items': []});
        return json({
          'errors': [
            {'message': 'nope'},
          ],
        });
      }).fetchActivity(
        't',
        login: 'me',
        since: DateTime.utc(2026),
        until: DateTime.utc(2026, 2),
      ),
      failsWith(GitHubFailureKind.unavailable),
    );
  });
}
