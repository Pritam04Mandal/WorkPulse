import 'package:intl/intl.dart';

import '../../../core/domain/enums.dart';
import '../../../core/format/durations.dart';
import '../../tracking/domain/usage_models.dart';

class CategoryTime {
  const CategoryTime(this.category, this.label, this.duration);

  final ActivityCategory category;
  final String label;
  final Duration duration;
}

enum DashboardDestination {
  timeline,
  projects,
  insights,
  github,
  integrations,
  journal,
}

class StatTile {
  const StatTile({
    required this.label,
    required this.value,
    required this.caption,
    required this.destination,
  });

  final String label;
  final String value;
  final String caption;
  final DashboardDestination destination;
}

enum RecentKind { coding, ai, meeting, github, other }

class RecentActivity {
  const RecentActivity({
    required this.entryId,
    required this.time,
    required this.kind,
    required this.title,
    required this.subtitle,
    this.duration,
  });

  /// The event this row opens.
  final String entryId;
  final String time;
  final RecentKind kind;
  final String title;
  final String subtitle;

  /// Null for point events such as opening a pull request.
  final Duration? duration;
}

class DashboardSummary {
  const DashboardSummary({
    required this.categories,
    required this.latest,
    required this.tiles,
    required this.recent,
    required this.dailySummary,
    required this.integrationsLabel,
  });

  final List<CategoryTime> categories;
  final RecentActivity? latest;
  final List<StatTile> tiles;
  final List<RecentActivity> recent;
  final String dailySummary;
  final String integrationsLabel;

  Duration get activeTime =>
      categories.fold(Duration.zero, (sum, c) => sum + c.duration);
}

const _gitKinds = {
  ActivityKind.commit,
  ActivityKind.pullRequest,
  ActivityKind.issue,
  ActivityKind.review,
};

const _categoryLabels = {
  ActivityCategory.coding: 'Coding',
  ActivityCategory.ai: 'AI assistants',
  ActivityCategory.meetings: 'Meetings',
  ActivityCategory.other: 'Other apps',
};

RecentKind _recentKind(TrackedActivity activity) {
  if (_gitKinds.contains(activity.kind)) return RecentKind.github;
  return switch (activity.category) {
    ActivityCategory.coding => RecentKind.coding,
    ActivityCategory.ai => RecentKind.ai,
    ActivityCategory.meetings => RecentKind.meeting,
    ActivityCategory.other => RecentKind.other,
  };
}

RecentActivity _recent(TrackedActivity activity) => RecentActivity(
  entryId: activity.id,
  time: DateFormat('HH:mm').format(activity.start),
  kind: _recentKind(activity),
  title: activity.title,
  subtitle: '${activity.sourceLabel} · observed',
  duration: activity.duration,
);

/// Summarises one day. Private events never count towards anything here.
DashboardSummary buildDashboardSummary(
  List<TrackedActivity> activities, {
  required bool usageGranted,
  bool githubConnected = false,
  String? Function(TrackedActivity)? projectOf,
}) {
  String? project(TrackedActivity a) =>
      projectOf == null ? a.projectId : projectOf(a);

  final visible = activities.where((a) => !a.isPrivate).toList();
  final timed = visible.where((a) => a.duration != null).toList();

  Duration totalOf(Iterable<TrackedActivity> items) =>
      items.fold(Duration.zero, (sum, a) => sum + a.duration!);

  final byApp = <String, Duration>{};
  for (final activity in timed) {
    byApp.update(
      activity.title,
      (time) => time + activity.duration!,
      ifAbsent: () => activity.duration!,
    );
  }
  final top = byApp.entries.isEmpty
      ? null
      : byApp.entries.reduce((a, b) => a.value >= b.value ? a : b);

  final aiCounts = <String, int>{};
  for (final activity in visible.where(
    (a) => a.category == ActivityCategory.ai,
  )) {
    aiCounts.update(
      activity.title.split(' · ').first,
      (n) => n + 1,
      ifAbsent: () => 1,
    );
  }
  final aiSessions = aiCounts.values.fold(0, (sum, n) => sum + n);

  final gitEvents = visible.where((a) => _gitKinds.contains(a.kind)).length;
  int countKind(ActivityKind kind) =>
      visible.where((a) => a.kind == kind).length;
  String plural(int n, String word) => '$n $word${n == 1 ? '' : 's'}';
  final gitCaption = [
    if (countKind(ActivityKind.commit) > 0)
      plural(countKind(ActivityKind.commit), 'commit'),
    if (countKind(ActivityKind.pullRequest) > 0)
      plural(countKind(ActivityKind.pullRequest), 'PR'),
    if (countKind(ActivityKind.review) > 0)
      plural(countKind(ActivityKind.review), 'review'),
    if (countKind(ActivityKind.issue) > 0)
      plural(countKind(ActivityKind.issue), 'issue'),
  ].join(' · ');
  final sources = visible.map((a) => a.sourceLabel).toSet();
  final projects = visible.map(project).nonNulls.toSet().length;
  final unassigned = totalOf(timed.where((a) => project(a) == null));

  return DashboardSummary(
    categories: [
      for (final MapEntry(key: category, value: label)
          in _categoryLabels.entries)
        CategoryTime(
          category,
          label,
          totalOf(timed.where((a) => a.category == category)),
        ),
    ],
    latest: visible.isEmpty ? null : _recent(visible.last),
    tiles: [
      StatTile(
        label: 'Observed events',
        value: '${visible.length}',
        caption: switch (sources.length) {
          0 => 'none yet today',
          1 => 'from ${sources.single}',
          final n => 'from $n sources',
        },
        destination: DashboardDestination.timeline,
      ),
      StatTile(
        label: 'Active projects',
        value: '$projects',
        caption: '${formatDuration(unassigned)} unassigned',
        destination: DashboardDestination.projects,
      ),
      StatTile(
        label: 'GitHub',
        value: '$gitEvents',
        caption: gitEvents > 0
            ? gitCaption
            : githubConnected
            ? 'Nothing today'
            : 'Not connected',
        destination: DashboardDestination.github,
      ),
      StatTile(
        label: 'AI sessions',
        value: '$aiSessions',
        caption: aiCounts.isEmpty
            ? 'None today'
            : aiCounts.entries.map((e) => '${e.key} ${e.value}').join(' · '),
        destination: DashboardDestination.insights,
      ),
    ],
    recent: visible.reversed.take(4).map(_recent).toList(),
    dailySummary: top == null
        ? 'Nothing recorded yet today.'
        : 'Most time went to ${top.key} (${formatDuration(top.value)}). '
              '${byApp.length} ${byApp.length == 1 ? 'app' : 'apps'} used '
              'across ${timed.length} '
              '${timed.length == 1 ? 'session' : 'sessions'}.',
    integrationsLabel: switch ((usageGranted ? 1 : 0) +
        (githubConnected ? 1 : 0)) {
      0 => 'No sources connected',
      1 => '1 source connected',
      final n => '$n sources connected',
    },
  );
}
