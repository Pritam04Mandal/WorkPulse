import 'package:flutter/material.dart' show TimeOfDay;

import '../../../core/domain/enums.dart';
import '../../tracking/domain/usage_models.dart';
import 'timeline_entry.dart';

/// Quiet stretches shorter than this are normal phone use, not gaps.
const minTimelineGap = Duration(minutes: 30);

EntryKind entryKindFor(TrackedActivity activity) {
  if (activity.isPrivate) return EntryKind.private;
  if (activity.kind != ActivityKind.appUsage &&
      activity.kind != ActivityKind.codingSession &&
      activity.kind != ActivityKind.aiSession &&
      activity.kind != ActivityKind.meeting &&
      activity.kind != ActivityKind.browsing) {
    return EntryKind.github;
  }
  return switch (activity.category) {
    ActivityCategory.coding => EntryKind.coding,
    ActivityCategory.ai => EntryKind.ai,
    ActivityCategory.meetings => EntryKind.meeting,
    ActivityCategory.other => EntryKind.other,
  };
}

TimelineEntry _entryFor(TrackedActivity activity) => TimelineEntry(
  id: activity.id,
  kind: entryKindFor(activity),
  start: TimeOfDay.fromDateTime(activity.start),
  end: activity.end == null ? null : TimeOfDay.fromDateTime(activity.end!),
  elapsed: activity.duration,
  title: activity.isPrivate ? 'Private session' : activity.title,
  source: activity.isPrivate ? 'Details hidden' : activity.sourceLabel,
  tag: activity.isPrivate
      ? 'Excluded from reports'
      : activity.isCorrected
      ? 'Corrected by you'
      : activity.repository != null
      ? '${activity.repository} · observed'
      : 'Observed',
  attribution: activity.isPrivate ? Attribution.hidden : Attribution.observed,
);

/// Orders a day's activity into rows, with gaps between quiet stretches.
List<TimelineEntry> buildTimelineEntries(List<TrackedActivity> activities) {
  final rows = <TimelineEntry>[];
  DateTime? lastEnd;
  for (final activity in activities) {
    final previous = lastEnd;
    if (previous != null &&
        activity.start.difference(previous) >= minTimelineGap) {
      rows.add(
        TimelineEntry(
          id: 'gap-${previous.millisecondsSinceEpoch}',
          kind: EntryKind.gap,
          start: TimeOfDay.fromDateTime(previous),
          end: TimeOfDay.fromDateTime(activity.start),
          elapsed: activity.start.difference(previous),
        ),
      );
    }
    rows.add(_entryFor(activity));
    final end = activity.end ?? activity.start;
    if (previous == null || end.isAfter(previous)) lastEnd = end;
  }
  return rows;
}

/// Tracked time, leaving out gaps and private sessions.
Duration trackedTime(List<TimelineEntry> rows) => rows
    .where((e) => !e.isGap && e.kind != EntryKind.private && e.duration != null)
    .fold(Duration.zero, (sum, e) => sum + e.duration!);

Duration gapTime(List<TimelineEntry> rows) => rows
    .where((e) => e.isGap)
    .fold(Duration.zero, (sum, e) => sum + e.duration!);
