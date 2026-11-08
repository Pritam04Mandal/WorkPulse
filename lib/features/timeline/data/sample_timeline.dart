import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/timeline_entry.dart';

const _todayEntries = [
  TimelineEntry(
    id: 'vscode',
    kind: EntryKind.coding,
    start: TimeOfDay(hour: 9, minute: 12),
    end: TimeOfDay(hour: 10, minute: 50),
    title: 'VS Code',
    source: 'Desktop companion',
    tag: 'workpulse-app · inferred 81%',
    attribution: Attribution.inferred,
    confidence: 81,
    project: 'workpulse-app',
    reason:
        'Workspace path matches the cloned repository '
        'github.com/sample/workpulse-app.',
    application: 'code',
    workspace: '~/code/workpulse-app',
    mergedFrom: 14,
  ),
  TimelineEntry(
    id: 'sprint',
    kind: EntryKind.meeting,
    start: TimeOfDay(hour: 10, minute: 0),
    end: TimeOfDay(hour: 10, minute: 45),
    title: 'Sprint planning',
    source: 'Teams calendar',
    tag: 'Observed',
    project: 'Client meetings',
    reason: 'Calendar event synced from Microsoft Teams.',
  ),
  TimelineEntry(
    id: 'gap',
    kind: EntryKind.gap,
    start: TimeOfDay(hour: 10, minute: 45),
    end: TimeOfDay(hour: 11, minute: 5),
  ),
  TimelineEntry(
    id: 'chatgpt',
    kind: EntryKind.ai,
    start: TimeOfDay(hour: 11, minute: 5),
    end: TimeOfDay(hour: 11, minute: 29),
    title: 'ChatGPT session',
    source: 'Browser extension',
    tag: 'Unassigned',
    attribution: Attribution.unassigned,
    reason: 'No repository, rule or tag matched this session.',
    application: 'chatgpt.com',
  ),
  TimelineEntry(
    id: 'commit',
    kind: EntryKind.github,
    start: TimeOfDay(hour: 11, minute: 40),
    title: 'Commit · Add drift migrations',
    source: 'GitHub',
    tag: 'workpulse-app · observed',
    project: 'workpulse-app',
    reason: 'Pushed to github.com/sample/workpulse-app.',
  ),
  TimelineEntry(
    id: 'private',
    kind: EntryKind.private,
    start: TimeOfDay(hour: 12, minute: 10),
    end: TimeOfDay(hour: 12, minute: 40),
    title: 'Private session',
    source: 'Details hidden',
    tag: 'Excluded from reports',
    attribution: Attribution.hidden,
  ),
  TimelineEntry(
    id: 'pr42',
    kind: EntryKind.github,
    start: TimeOfDay(hour: 12, minute: 58),
    title: 'Opened PR #42',
    source: 'GitHub',
    tag: 'workpulse-app · observed',
    project: 'workpulse-app',
    reason: 'Opened on github.com/sample/workpulse-app.',
  ),
  TimelineEntry(
    id: 'claude',
    kind: EntryKind.ai,
    start: TimeOfDay(hour: 13, minute: 42),
    end: TimeOfDay(hour: 14, minute: 0),
    title: 'Claude session',
    source: 'Browser extension',
    tag: 'workpulse-app · you set',
    attribution: Attribution.setByYou,
    project: 'workpulse-app',
    reason: 'You assigned this session.',
    application: 'claude.ai',
  ),
];

/// Today's sample events. Deleting one removes it until the app restarts.
class SampleTimeline extends Notifier<List<TimelineEntry>> {
  @override
  List<TimelineEntry> build() => _todayEntries;

  void remove(String id) =>
      state = state.where((entry) => entry.id != id).toList();
}

final sampleTimelineProvider =
    NotifierProvider<SampleTimeline, List<TimelineEntry>>(SampleTimeline.new);
