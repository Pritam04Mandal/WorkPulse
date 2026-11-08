import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workpulse/core/database/app_database.dart';
import 'package:workpulse/core/database/setting_keys.dart';
import 'package:workpulse/core/domain/enums.dart';
import 'package:workpulse/features/companion/data/companion_repository.dart';
import 'package:workpulse/features/companion/data/companion_secrets.dart';
import 'package:workpulse/features/companion/data/companion_server.dart';
import 'package:workpulse/features/companion/domain/companion_models.dart';
import 'package:workpulse/features/companion/domain/pairing_crypto.dart';

const _script = 'companion/claude-code/workpulse_claude.py';

class MemorySecrets implements CompanionSecrets {
  final values = <String, String>{};

  @override
  Future<void> clear() async => values.clear();

  @override
  Future<void> delete(String deviceId) async => values.remove(deviceId);

  @override
  Future<String?> read(String deviceId) async => values[deviceId];

  @override
  Future<void> save(String deviceId, String secret) async =>
      values[deviceId] = secret;
}

/// Runs the real Python script against the real receiver over a real socket.
void main() {
  late AppDatabase db;
  late MemorySecrets secrets;
  late CompanionRepository repository;
  late CompanionServer server;
  late Directory home;
  late Map<String, String> env;
  final liveReports = <(Set<String>, Set<String>)>[];

  String address() => '127.0.0.1:${server.port}';

  Future<ProcessResult> run(List<String> arguments) =>
      Process.run('python3', [_script, ...arguments], environment: env);

  Future<ProcessResult> hook(
    String event, {
    String session = 'sess-1',
    int? atMs,
    String extra = '',
  }) async {
    final process = await Process.start(
      'python3',
      [_script, 'hook'],
      environment: {...env, if (atMs != null) 'WORKPULSE_NOW_MS': '$atMs'},
    );
    process.stdin.write(
      '{"session_id":"$session","hook_event_name":"$event",'
      '"cwd":"${Directory.current.path}"$extra}',
    );
    await process.stdin.close();
    final out = await process.stdout.transform(utf8.decoder).join();
    final code = await process.exitCode;
    return ProcessResult(process.pid, code, out, '');
  }

  Future<List<ActivityEvent>> events() => db.select(db.activityEvents).get();

  /// Hooks send from a detached process, so wait for it to land.
  Future<List<ActivityEvent>> eventually(
    bool Function(List<ActivityEvent>) done,
  ) async {
    for (var i = 0; i < 60; i++) {
      final rows = await events();
      if (done(rows)) return rows;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    return events();
  }

  Future<void> pairDevice() async {
    final code = server.beginPairing().code;
    final result = await run(['pair', address(), code]);
    expect(result.exitCode, 0, reason: '${result.stderr}');
  }

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    secrets = MemorySecrets();
    repository = CompanionRepository(database: db, secrets: secrets);
    liveReports.clear();
    server = CompanionServer(
      repository,
      onLive: (working, finished) => liveReports.add((working, finished)),
    );
    await server.start(port: 0);
    home = await Directory.systemTemp.createTemp('workpulse-test');
    env = {
      'WORKPULSE_HOME': '${home.path}/state',
      'CLAUDE_CONFIG_DIR': '${home.path}/claude',
      'WORKPULSE_TICK_S': '0.1',
    };
  });

  tearDown(() async {
    await server.stop();
    await db.close();
    await home.delete(recursive: true);
  });

  test('pairing with the right code stores a matching secret', () async {
    await pairDevice();

    final device = await db.select(db.pairedDevices).getSingle();
    expect(device.name, isNotEmpty);
    final config = jsonDecode(
      File('${home.path}/state/config.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    expect(secrets.values[device.id], config['secret']);
    expect(device.publicKey, isNot(contains(config['secret'] as String)));
  });

  test('the wrong code is rejected and pairs nothing', () async {
    server.beginPairing();
    final result = await run(['pair', address(), '000000x']);

    expect(result.exitCode, 1);
    expect('${result.stderr}', contains('wrong or has expired'));
    expect(await db.select(db.pairedDevices).get(), isEmpty);
  });

  test('without an active pairing nothing can pair', () async {
    final result = await run(['pair', address(), '123456']);
    expect(result.exitCode, 1);
    expect(await db.select(db.pairedDevices).get(), isEmpty);
  });

  test('a session reaches the phone and extends live', () async {
    await pairDevice();
    final start = DateTime.now().millisecondsSinceEpoch - 600000;

    final prompt = await hook(
      'UserPromptSubmit',
      atMs: start,
      extra: ',"prompt":"my secret prompt text"',
    );
    expect(prompt.exitCode, 0);
    expect(prompt.stdout, isEmpty);

    await hook('Stop', atMs: start + 60000);
    var rows = await eventually(
      (r) => r.isNotEmpty && r.single.endedAt != null,
    );
    final row = rows.single;
    expect(row.kind, ActivityKind.aiSession);
    expect(row.category, ActivityCategory.ai);
    expect(row.application, claudeCodeApplication);
    expect(row.title, startsWith('Claude Code · '));

    await hook('UserPromptSubmit', atMs: start + 120000);
    await hook('Stop', atMs: start + 300000);
    rows = await eventually(
      (r) => r.single.endedAt!.difference(r.single.startedAt).inSeconds == 300,
    );
    expect(rows, hasLength(1));
    expect(
      rows.single.endedAt!.difference(rows.single.startedAt).inSeconds,
      300,
    );

    final state = File('${home.path}/state/state.json').readAsStringSync();
    expect(state, isNot(contains('my secret prompt text')));
    expect(rows.single.title, isNot(contains('my secret prompt text')));
  });

  group('live updates', () {
    Future<bool> until(bool Function() done) async {
      for (var i = 0; i < 80 && !done(); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      return done();
    }

    test('a prompt appears at once and counts prompts, with no text', () async {
      await pairDevice();
      final start = DateTime.now().millisecondsSinceEpoch;

      await hook(
        'UserPromptSubmit',
        atMs: start,
        extra: ',"prompt":"do not send this"',
      );
      var rows = await eventually((r) => r.isNotEmpty);
      expect(rows.single.mergedEventCount, 1);
      expect(rows.single.title, isNot(contains('do not send')));
      expect(
        await until(() => liveReports.any((r) => r.$1.isNotEmpty)),
        isTrue,
      );

      await hook('UserPromptSubmit', atMs: start + 1000);
      rows = await eventually((r) => r.single.mergedEventCount == 2);
      expect(rows.single.mergedEventCount, 2);
    });

    test('finishing clears the live state', () async {
      await pairDevice();
      final start = DateTime.now().millisecondsSinceEpoch;

      await hook('UserPromptSubmit', atMs: start);
      expect(
        await until(() => liveReports.any((r) => r.$1.isNotEmpty)),
        isTrue,
      );
      await hook('Stop', atMs: start + 2000);

      expect(
        await until(() => liveReports.any((r) => r.$2.isNotEmpty)),
        isTrue,
      );
    });

    test('heartbeats extend a session while the transcript changes', () async {
      await pairDevice();
      final transcript = File('${home.path}/transcript.jsonl')
        ..writeAsStringSync('');
      await hook(
        'UserPromptSubmit',
        extra: ',"transcript_path":"${transcript.path}"',
      );
      await eventually((r) => r.isNotEmpty);

      await Future<void>.delayed(const Duration(milliseconds: 2200));
      transcript.writeAsStringSync('more');

      final rows = await eventually(
        (r) => r.single.endedAt!.difference(r.single.startedAt).inSeconds >= 2,
      );
      expect(
        rows.single.endedAt!.difference(rows.single.startedAt).inSeconds,
        greaterThanOrEqualTo(2),
      );
    });

    test('an interrupted turn stops being live on its own', () async {
      await pairDevice();
      // No transcript activity and no Stop hook: what an interrupt looks like.
      await hook('UserPromptSubmit');

      expect(
        await until(() => liveReports.any((r) => r.$2.isNotEmpty)),
        isTrue,
      );
    });
  });

  test('coming back after the idle gap starts a new segment', () async {
    await pairDevice();
    final start = DateTime.now().millisecondsSinceEpoch - 3600000;

    await hook('UserPromptSubmit', atMs: start);
    await hook('Stop', atMs: start + 60000);
    await hook('UserPromptSubmit', atMs: start + 1800000);
    await hook('Stop', atMs: start + 1860000);

    final rows = await eventually((r) => r.length == 2);
    expect(rows, hasLength(2));
  });

  test('sessions queue while the phone is away, then arrive', () async {
    await pairDevice();
    final port = server.port!;
    await server.stop();
    final start = DateTime.now().millisecondsSinceEpoch - 600000;

    await hook('UserPromptSubmit', atMs: start);
    final stop = await hook('Stop', atMs: start + 60000);
    expect(stop.exitCode, 0);
    await run(['flush']);
    expect(await events(), isEmpty);
    expect('${(await run(['status'])).stdout}', contains('waiting to send: 1'));

    await server.start(port: port);
    await run(['flush']);

    expect(await eventually((r) => r.isNotEmpty), hasLength(1));
    expect('${(await run(['status'])).stdout}', contains('waiting to send: 0'));
  });

  group('VS Code extension protocol', () {
    const client = 'companion/vscode/test/e2e_client.js';

    Future<ProcessResult> node(List<String> arguments) =>
        Process.run('node', [client, ...arguments], environment: env);

    test('pairs and sends coding time', () async {
      final code = server.beginPairing().code;
      final paired = await node(['pair', address(), code]);
      expect(paired.exitCode, 0, reason: '${paired.stderr}');

      final device = await db.select(db.pairedDevices).getSingle();
      final config = jsonDecode(
        File('${home.path}/state/config.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      expect(secrets.values[device.id], config['secret']);

      final start = DateTime.now().millisecondsSinceEpoch - 120000;
      final sent = await node(['send', 'my-app', '$start', '${start + 60000}']);
      expect(sent.stdout, 'sent', reason: '${sent.stderr}');

      final row = (await events()).single;
      expect(row.kind, ActivityKind.codingSession);
      expect(row.category, ActivityCategory.coding);
      expect(row.title, 'VS Code · my-app');
      expect(row.application, vscodeApplication);
      expect(row.domain, 'me/app');
    });

    test('uses a pairing made by the Claude script', () async {
      await pairDevice();

      final start = DateTime.now().millisecondsSinceEpoch - 120000;
      final sent = await node(['send', 'shared', '$start', '${start + 1000}']);

      expect(sent.stdout, 'sent', reason: '${sent.stderr}');
      expect(await events(), hasLength(1));
    });

    test('the wrong code is rejected', () async {
      server.beginPairing();
      final paired = await node(['pair', address(), 'nope']);
      expect(paired.exitCode, 1);
      expect('${paired.stderr}', contains('wrong or has expired'));
      expect(await db.select(db.pairedDevices).get(), isEmpty);
    });
  });

  test('an unknown segment kind is refused by the parser', () {
    final now = DateTime(2026, 11, 9, 12);
    final start = now.millisecondsSinceEpoch - 1000;
    Object segment(String? kind) => {
      'id': 'a.1',
      'project': 'p',
      'start': start,
      'end': start + 500,
      'kind': ?kind,
    };

    expect(
      ClaudeSegment.parse(segment('vscode'), now: now)?.source,
      SegmentSource.vscode,
    );
    expect(
      ClaudeSegment.parse(segment(null), now: now)?.source,
      SegmentSource.claudeCode,
    );
    expect(ClaudeSegment.parse(segment('mystery'), now: now), isNull);
  });

  group('rejected events', () {
    Future<HttpClientResponse> send(
      Map<String, String> headers,
      String body,
    ) async {
      final client = HttpClient();
      final request = await client.postUrl(
        Uri.parse('http://${address()}/v1/events'),
      );
      headers.forEach(request.headers.set);
      request.write(body);
      final response = await request.close();
      await response.drain<void>();
      client.close();
      return response;
    }

    Future<Map<String, String>> signed(String body, {String? secret}) async {
      final device = await db.select(db.pairedDevices).getSingle();
      final timestamp = '${DateTime.now().millisecondsSinceEpoch}';
      return {
        'x-workpulse-device': device.id,
        'x-workpulse-timestamp': timestamp,
        'x-workpulse-signature': signEvents(
          secret ?? secrets.values[device.id]!,
          timestamp,
          body,
        ),
      };
    }

    String segmentBody() {
      final start = DateTime.now().millisecondsSinceEpoch - 60000;
      return jsonEncode({
        'segments': [
          {'id': 'a.1', 'project': 'p', 'start': start, 'end': start + 1000},
        ],
      });
    }

    test('a bad signature changes nothing', () async {
      await pairDevice();
      final body = segmentBody();
      final response = await send(await signed(body, secret: 'wrong'), body);
      expect(response.statusCode, 401);
      expect(await events(), isEmpty);
    });

    test('an unknown device is refused', () async {
      await pairDevice();
      final body = segmentBody();
      final headers = await signed(body);
      headers['x-workpulse-device'] = 'nobody';
      expect((await send(headers, body)).statusCode, 401);
    });

    test('a correct signature is accepted', () async {
      await pairDevice();
      final body = segmentBody();
      expect((await send(await signed(body), body)).statusCode, 200);
      expect(await events(), hasLength(1));
    });

    test('nothing is recorded during a private session', () async {
      await pairDevice();
      await db.writeSetting(privateSessionSettingKey, 'true');
      final body = segmentBody();
      expect((await send(await signed(body), body)).statusCode, 200);
      expect(await events(), isEmpty);
    });
  });

  test('malformed segments are refused by the parser', () {
    final now = DateTime(2026, 11, 9, 12);
    final start = now.millisecondsSinceEpoch - 1000;
    Map<String, Object?> segment(Map<String, Object?> change) => {
      'id': 'a.1',
      'project': 'p',
      'start': start,
      'end': start + 500,
      ...change,
    };

    expect(ClaudeSegment.parse(segment({}), now: now), isNotNull);
    for (final bad in <Map<String, Object?>>[
      {'id': 'has spaces'},
      {'project': ''},
      {'end': start - 1},
      {'end': start + const Duration(hours: 25).inMilliseconds},
      {'repo': 5},
      {'start': 'soon'},
    ]) {
      expect(
        ClaudeSegment.parse(segment(bad), now: now),
        isNull,
        reason: '$bad',
      );
    }
  });

  test('unpairing can delete its sessions and drops the key', () async {
    await pairDevice();
    final device = await db.select(db.pairedDevices).getSingle();
    final now = DateTime.now().millisecondsSinceEpoch;
    await repository.ingest(device.id, [
      ClaudeSegment(id: 'a.1', project: 'p', startMs: now - 5000, endMs: now),
    ]);
    expect(await events(), hasLength(1));

    await repository.unpair(device.id, keepEvents: false);

    expect(await events(), isEmpty);
    expect(secrets.values, isEmpty);
    expect(await db.select(db.pairedDevices).get(), isEmpty);
  });

  group('installing hooks', () {
    File settings() => File('${home.path}/claude/settings.json');

    test('keeps existing settings and can be undone', () async {
      settings()
        ..createSync(recursive: true)
        ..writeAsStringSync(
          jsonEncode({
            'theme': 'dark',
            'hooks': {
              'Stop': [
                {
                  'hooks': [
                    {'type': 'command', 'command': 'my-own-hook'},
                  ],
                },
              ],
            },
          }),
        );

      expect((await run(['install'])).exitCode, 0);
      expect((await run(['install'])).exitCode, 0);

      var saved = jsonDecode(settings().readAsStringSync()) as Map;
      expect(saved['theme'], 'dark');
      expect(saved['hooks']['Stop'], hasLength(2));
      expect(saved['hooks']['UserPromptSubmit'], hasLength(1));
      expect(saved['hooks']['SessionEnd'], hasLength(1));
      expect(saved['hooks']['PreToolUse'][0]['hooks'][0]['async'], isTrue);

      expect((await run(['uninstall'])).exitCode, 0);
      saved = jsonDecode(settings().readAsStringSync()) as Map;
      expect(saved['theme'], 'dark');
      expect(saved['hooks']['Stop'], hasLength(1));
      expect(saved['hooks'].containsKey('UserPromptSubmit'), isFalse);
    });

    test('refuses to touch an invalid settings file', () async {
      settings()
        ..createSync(recursive: true)
        ..writeAsStringSync('{ not json');

      expect((await run(['install'])).exitCode, 1);
      expect(settings().readAsStringSync(), '{ not json');
    });
  });
}
