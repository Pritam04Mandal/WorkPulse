import '../../../core/domain/enums.dart';

enum UsageEventType { resumed, paused, screenOff }

/// A foreground transition from Android's usage log.
class RawUsageEvent {
  const RawUsageEvent(this.package, this.type, this.timeMs);

  final String package;
  final UsageEventType type;
  final int timeMs;
}

/// One continuous stretch of an app being in the foreground.
class AppSession {
  const AppSession({
    required this.package,
    required this.startMs,
    required this.endMs,
    this.mergedEvents = 1,
  });

  final String package;
  final int startMs;
  final int endMs;
  final int mergedEvents;

  /// Stable across re-reads of the log, so a re-import is a no-op.
  String get externalId => '$package:$startMs';
}

class InstalledApp {
  const InstalledApp(this.package, this.label);

  final String package;
  final String label;
}

/// An event as the screens see it.
class TrackedActivity {
  const TrackedActivity({
    required this.id,
    required this.kind,
    required this.category,
    required this.title,
    required this.start,
    this.end,
    this.externalId,
    this.application,
    this.repository,
    this.projectId,
    this.mergedEvents = 1,
    this.isPrivate = false,
    this.isCorrected = false,
  });

  final String id;
  final ActivityKind kind;
  final ActivityCategory category;
  final String title;
  final DateTime start;

  /// Null for point events such as a commit.
  final DateTime? end;
  final String? externalId;
  final String? application;

  /// `owner/name`, for events from a Git host.
  final String? repository;
  final String? projectId;
  final int mergedEvents;
  final bool isPrivate;
  final bool isCorrected;

  Duration? get duration => end?.difference(start);

  String get sourceLabel => switch (kind) {
    ActivityKind.appUsage => 'Android usage',
    ActivityKind.aiSession => 'Claude Code',
    ActivityKind.codingSession => 'VS Code',
    _ => 'GitHub',
  };
}

DateTime startOfDay(DateTime time) => DateTime(time.year, time.month, time.day);

/// Monday of the week containing [time].
DateTime startOfWeek(DateTime time) =>
    DateTime(time.year, time.month, time.day - (time.weekday - 1));
