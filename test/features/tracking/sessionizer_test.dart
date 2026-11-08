import 'package:flutter_test/flutter_test.dart';
import 'package:workpulse/features/tracking/domain/sessionizer.dart';
import 'package:workpulse/features/tracking/domain/usage_models.dart';

const _s = 1000;

RawUsageEvent resumed(String p, int t) =>
    RawUsageEvent(p, UsageEventType.resumed, t * _s);
RawUsageEvent paused(String p, int t) =>
    RawUsageEvent(p, UsageEventType.paused, t * _s);
RawUsageEvent screenOff(int t) =>
    RawUsageEvent('android', UsageEventType.screenOff, t * _s);

SessionizerResult run(List<RawUsageEvent> events, {int now = 100000}) =>
    buildSessions(events, cursorMs: 0, nowMs: now * _s);

void main() {
  test('a pause then a switch closes the session at the pause', () {
    final result = run([
      resumed('a', 10),
      paused('a', 70),
      resumed('b', 71),
      paused('b', 100),
    ]);
    final a = result.sessions.first;
    expect(a.package, 'a');
    expect(a.startMs, 10 * _s);
    expect(a.endMs, 70 * _s);
    expect(result.sessions[1].package, 'b');
  });

  test('moving between screens of one app is one session', () {
    final result = run([
      resumed('a', 10),
      paused('a', 20),
      resumed('a', 21),
      paused('a', 40),
      resumed('a', 45),
      paused('a', 90),
    ]);
    expect(result.sessions, hasLength(1));
    expect(result.sessions.single.endMs, 90 * _s);
    expect(result.sessions.single.mergedEvents, 3);
  });

  test('returning after the merge window starts a new session', () {
    final result = run([
      resumed('a', 10),
      paused('a', 20),
      resumed('a', 60),
      paused('a', 90),
    ]);
    expect(result.sessions, hasLength(2));
  });

  test('sessions under the minimum are dropped', () {
    final result = run([resumed('a', 10), paused('a', 13)]);
    expect(result.sessions, isEmpty);
  });

  test('screen off ends the session', () {
    final result = run([resumed('a', 10), screenOff(50)]);
    expect(result.sessions.single.endMs, 50 * _s);
  });

  test('an open session is held back and the cursor stays at its start', () {
    final result = run([resumed('a', 10)], now: 500);
    expect(result.sessions, isEmpty);
    expect(result.nextCursorMs, 10 * _s);
  });

  test('a recent pause stays open in case the app comes back', () {
    final result = run([resumed('a', 10), paused('a', 50)], now: 60);
    expect(result.sessions, isEmpty);
    expect(result.nextCursorMs, 10 * _s);
  });

  test('re-reading from the cursor yields the same session id', () {
    final first = run([resumed('a', 10), paused('a', 50)], now: 60);
    final second = buildSessions(
      [resumed('a', 10), paused('a', 50), resumed('b', 200)],
      cursorMs: first.nextCursorMs,
      nowMs: 300 * _s,
    );
    expect(second.sessions.single.externalId, 'a:${10 * _s}');
  });

  test('with no events the cursor does not move', () {
    final result = buildSessions(const [], cursorMs: 42, nowMs: 900);
    expect(result.nextCursorMs, 42);
  });

  test('a pause for another app is ignored', () {
    final result = run([
      resumed('a', 10),
      paused('b', 12),
      resumed('b', 60),
      paused('b', 90),
    ]);
    expect(result.sessions.first.endMs, 60 * _s);
  });

  test('sessions crossing midnight are split between the days', () {
    final midnight = DateTime(2026, 11, 9).millisecondsSinceEpoch;
    final parts = splitAtMidnight(
      AppSession(
        package: 'a',
        startMs: midnight - 600 * _s,
        endMs: midnight + 300 * _s,
      ),
    );
    expect(parts, hasLength(2));
    expect(parts.first.endMs, midnight - 1);
    expect(parts.last.startMs, midnight);
    expect(parts.first.externalId, isNot(parts.last.externalId));
  });

  test('a session within one day is left whole', () {
    final start = DateTime(2026, 11, 9, 10).millisecondsSinceEpoch;
    final parts = splitAtMidnight(
      AppSession(package: 'a', startMs: start, endMs: start + 60 * _s),
    );
    expect(parts, hasLength(1));
  });
}
