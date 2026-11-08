import 'package:flutter/material.dart' show TimeOfDay;

import '../../../core/format/durations.dart';

enum EntryKind { coding, meeting, ai, github, other, private, gap }

enum Attribution { inferred, observed, setByYou, unassigned, hidden }

int minutesOf(TimeOfDay time) => time.hour * 60 + time.minute;

String clockLabel(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:'
    '${time.minute.toString().padLeft(2, '0')}';

Duration spanBetween(TimeOfDay start, TimeOfDay end) =>
    Duration(minutes: minutesOf(end) - minutesOf(start));

class TimelineEntry {
  const TimelineEntry({
    required this.id,
    required this.kind,
    required this.start,
    this.end,
    this.title = '',
    this.source = '',
    this.tag = '',
    this.attribution = Attribution.observed,
    this.confidence,
    this.project,
    this.reason,
    this.application,
    this.workspace,
    this.mergedFrom,
    this.elapsed,
    this.isLive = false,
  });

  final String id;
  final EntryKind kind;
  final TimeOfDay start;

  /// Null for point events such as a commit.
  final TimeOfDay? end;
  final String title;
  final String source;
  final String tag;
  final Attribution attribution;

  /// Percent, set when [attribution] is inferred.
  final int? confidence;
  final String? project;
  final String? reason;
  final String? application;
  final String? workspace;
  final int? mergedFrom;

  /// Exact length when known; [start] and [end] only have minute precision.
  final Duration? elapsed;

  /// Still in progress on a paired computer.
  final bool isLive;

  bool get isGap => kind == EntryKind.gap;
  bool get isInferred => attribution == Attribution.inferred;
  Duration? get duration =>
      elapsed ?? (end == null ? null : spanBetween(start, end!));
  String get displayTitle =>
      isGap ? 'No activity recorded · ${formatDuration(duration)}' : title;
}

enum TimelineFilter { all, coding, meeting, ai, github }

/// Applies a filter. Gaps only make sense on the unfiltered day.
List<TimelineEntry> filterEntries(
  List<TimelineEntry> entries,
  TimelineFilter filter,
) => filter == TimelineFilter.all
    ? entries
    : entries.where((e) => e.kind.name == filter.name).toList();
