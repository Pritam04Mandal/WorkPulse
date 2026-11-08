import 'usage_models.dart';

/// Leaving an app and returning within this window counts as one session.
const mergeGapMs = 30 * 1000;

/// Shorter stretches are app-switching noise.
const minSessionMs = 5 * 1000;

class SessionizerResult {
  const SessionizerResult(this.sessions, this.nextCursorMs);

  final List<AppSession> sessions;

  /// Where the next read should begin. Stays at the start of any session
  /// still open, so it is emitted whole once it closes.
  final int nextCursorMs;
}

/// Turns raw foreground transitions into closed app sessions.
SessionizerResult buildSessions(
  List<RawUsageEvent> events, {
  required int cursorMs,
  required int nowMs,
}) {
  final sessions = <AppSession>[];
  String? package;
  var startMs = 0;
  var merged = 0;
  int? pausedAt;
  int? lastEventMs;

  void close(int endMs) {
    if (endMs - startMs >= minSessionMs) {
      sessions.add(
        AppSession(
          package: package!,
          startMs: startMs,
          endMs: endMs,
          mergedEvents: merged,
        ),
      );
    }
    package = null;
    pausedAt = null;
  }

  void open(RawUsageEvent event) {
    package = event.package;
    startMs = event.timeMs;
    merged = 1;
    pausedAt = null;
  }

  final ordered = [...events]..sort((a, b) => a.timeMs.compareTo(b.timeMs));
  for (final event in ordered) {
    lastEventMs = event.timeMs;
    switch (event.type) {
      case UsageEventType.resumed:
        if (package == null) {
          open(event);
        } else if (package != event.package) {
          close(pausedAt ?? event.timeMs);
          open(event);
        } else if (pausedAt != null && event.timeMs - pausedAt! > mergeGapMs) {
          close(pausedAt!);
          open(event);
        } else {
          pausedAt = null;
          merged++;
        }
      case UsageEventType.paused:
        if (package == event.package) pausedAt ??= event.timeMs;
      case UsageEventType.screenOff:
        if (package != null) close(pausedAt ?? event.timeMs);
    }
  }

  if (package != null && pausedAt != null && nowMs - pausedAt! > mergeGapMs) {
    close(pausedAt!);
  }

  final next = package != null
      ? startMs
      : lastEventMs == null
      ? cursorMs
      : lastEventMs + 1;
  return SessionizerResult(sessions, next);
}

/// Splits a session at local midnights, so each part belongs to one day.
List<AppSession> splitAtMidnight(AppSession session) {
  final parts = <AppSession>[];
  var startMs = session.startMs;
  while (true) {
    final day = DateTime.fromMillisecondsSinceEpoch(startMs);
    final nextDay = DateTime(
      day.year,
      day.month,
      day.day + 1,
    ).millisecondsSinceEpoch;
    if (session.endMs <= nextDay) {
      parts.add(_part(session, startMs, session.endMs));
      return parts;
    }
    parts.add(_part(session, startMs, nextDay - 1));
    startMs = nextDay;
  }
}

AppSession _part(AppSession session, int startMs, int endMs) => AppSession(
  package: session.package,
  startMs: startMs,
  endMs: endMs,
  mergedEvents: session.mergedEvents,
);
