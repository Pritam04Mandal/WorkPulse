import 'package:intl/intl.dart';

import '../../../core/domain/enums.dart';
import '../../../core/format/durations.dart';
import '../../projects/domain/project.dart';
import '../../projects/domain/project_matcher.dart';
import '../../tracking/domain/usage_models.dart';

const journalDisclaimer =
    'Built only from recorded events. Time is observed activity, not proof of '
    'output.';

class JournalReport {
  const JournalReport({
    required this.heading,
    required this.basis,
    required this.projects,
    required this.github,
    required this.highlights,
    this.codingSummary,
    this.tracked,
    this.attributed,
  });

  final String heading;
  final String basis;
  final List<(String, Duration)> projects;
  final List<String> github;
  final List<String> highlights;
  final String? codingSummary;

  /// Weekly reports only.
  final Duration? tracked;
  final Duration? attributed;

  bool get isEmpty => basis.startsWith('Nothing');

  String toPlainText() => [
    heading,
    basis,
    if (tracked != null) 'Tracked ${formatDuration(tracked)}',
    if (attributed != null) 'Attributed ${formatDuration(attributed)}',
    for (final (name, time) in projects) '$name: ${formatDuration(time)}',
    ...github.map((line) => '- $line'),
    ...highlights.map((line) => '- $line'),
    ?codingSummary,
    journalDisclaimer,
  ].join('\n');
}

const _gitKinds = {
  ActivityKind.commit,
  ActivityKind.pullRequest,
  ActivityKind.issue,
  ActivityKind.review,
};

const _maxGitLines = 8;

String _plural(int n, String word) => '$n $word${n == 1 ? '' : 's'}';

Duration _sum(Iterable<TrackedActivity> items) =>
    items.fold(Duration.zero, (total, a) => total + a.duration!);

List<(String, Duration)> _projectTimes(
  List<TrackedActivity> timed,
  List<Project> projects,
) {
  final totals = <String, Duration>{};
  var unassigned = Duration.zero;
  for (final activity in timed) {
    final project = matchProject(activity, projects);
    if (project == null) {
      unassigned += activity.duration!;
    } else {
      totals.update(
        project.name,
        (time) => time + activity.duration!,
        ifAbsent: () => activity.duration!,
      );
    }
  }
  final ranked = totals.entries.map((e) => (e.key, e.value)).toList()
    ..sort((a, b) => b.$2.compareTo(a.$2));
  return [
    ...ranked,
    if (unassigned > Duration.zero) ('Unassigned', unassigned),
  ];
}

/// A rule-based account of one day. Private events are left out.
JournalReport buildDailyReport(
  List<TrackedActivity> activities,
  List<Project> projects,
  DateTime day,
) {
  final visible = activities.where((a) => !a.isPrivate).toList();
  final timed = visible.where((a) => a.duration != null).toList();
  final coding = timed.where((a) => a.category == ActivityCategory.coding);
  final ai = timed.where((a) => a.category == ActivityCategory.ai);

  final summary = [
    if (coding.isNotEmpty)
      '${formatDuration(_sum(coding))} of coding across '
          '${_plural(coding.length, 'session')}.',
    if (ai.isNotEmpty)
      '${_plural(ai.length, 'AI assistant session')} '
          '(${formatDuration(_sum(ai))}).',
  ].join(' ');

  return JournalReport(
    heading: DateFormat('EEEE, d MMMM').format(day),
    basis: visible.isEmpty
        ? 'Nothing recorded yet'
        : 'Rule-based · from ${_plural(visible.length, 'event')} · '
              '${formatDuration(_sum(timed))} tracked',
    projects: _projectTimes(timed, projects),
    github: visible.reversed
        .where((a) => _gitKinds.contains(a.kind))
        .take(_maxGitLines)
        .map((a) => '${a.title} (${a.repository})')
        .toList(),
    highlights: const [],
    codingSummary: summary.isEmpty ? null : summary,
  );
}

/// A rule-based account of one week. Private events are left out.
JournalReport buildWeeklyReport(
  List<TrackedActivity> activities,
  List<Project> projects,
  DateTime weekStart,
) {
  final visible = activities.where((a) => !a.isPrivate).toList();
  final timed = visible.where((a) => a.duration != null).toList();
  final attributed = timed.where((a) => matchProject(a, projects) != null);
  int count(ActivityKind kind) => visible.where((a) => a.kind == kind).length;

  final byDay = <DateTime, Duration>{};
  for (final activity in timed) {
    byDay.update(
      startOfDay(activity.start),
      (time) => time + activity.duration!,
      ifAbsent: () => activity.duration!,
    );
  }
  final busiest = byDay.isEmpty
      ? null
      : byDay.entries.reduce((a, b) => a.value >= b.value ? a : b);
  final git = [
    if (count(ActivityKind.commit) > 0)
      _plural(count(ActivityKind.commit), 'commit'),
    if (count(ActivityKind.pullRequest) > 0)
      _plural(count(ActivityKind.pullRequest), 'PR'),
    if (count(ActivityKind.review) > 0)
      _plural(count(ActivityKind.review), 'review'),
    if (count(ActivityKind.issue) > 0)
      _plural(count(ActivityKind.issue), 'issue'),
  ];

  return JournalReport(
    heading: 'Week of ${DateFormat('d MMMM').format(weekStart)}',
    basis: visible.isEmpty
        ? 'Nothing recorded yet'
        : 'Rule-based · from ${_plural(visible.length, 'event')}',
    projects: _projectTimes(timed, projects),
    github: const [],
    highlights: [
      if (git.isNotEmpty) 'GitHub: ${git.join(', ')}',
      if (busiest != null)
        'Busiest day: ${DateFormat('EEEE').format(busiest.key)}, '
            '${formatDuration(busiest.value)}',
    ],
    tracked: _sum(timed),
    attributed: _sum(attributed),
  );
}
