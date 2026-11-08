import '../../../core/domain/enums.dart';
import '../../projects/domain/project.dart';
import '../../projects/domain/project_matcher.dart';
import '../../tracking/domain/usage_models.dart';

enum InsightsPeriod { day, week, month }

(DateTime, DateTime) insightsRange(InsightsPeriod period, DateTime now) {
  switch (period) {
    case InsightsPeriod.day:
      final start = startOfDay(now);
      return (start, DateTime(start.year, start.month, start.day + 1));
    case InsightsPeriod.week:
      final start = startOfWeek(now);
      return (start, DateTime(start.year, start.month, start.day + 7));
    case InsightsPeriod.month:
      return (DateTime(now.year, now.month), DateTime(now.year, now.month + 1));
  }
}

class ProjectTime {
  const ProjectTime(this.name, this.time, {this.project});

  final String name;
  final Duration time;

  /// Null for the "Unassigned" row.
  final Project? project;
}

class InsightsData {
  const InsightsData({
    required this.heading,
    required this.labels,
    required this.usage,
    required this.attributed,
    required this.projects,
    required this.assistants,
    required this.topApps,
  });

  final String heading;
  final List<String> labels;
  final List<double> usage;
  final List<double> attributed;
  final List<ProjectTime> projects;
  final List<(String, Duration)> assistants;
  final List<(String, Duration)> topApps;

  Duration _total(List<double> hours) => Duration(
    seconds: (hours.fold<double>(0, (sum, h) => sum + h) * 3600).round(),
  );

  Duration get usageTotal => _total(usage);
  Duration get attributedTotal => _total(attributed);
  bool get isEmpty => usage.every((h) => h == 0);
}

List<(String, Duration)> _ranked(Map<String, Duration> totals) =>
    (totals.entries.map((e) => (e.key, e.value)).toList()
      ..sort((a, b) => b.$2.compareTo(a.$2)));

/// Summarises a period. Private events never count towards anything here.
InsightsData buildInsights(
  InsightsPeriod period,
  List<TrackedActivity> activities,
  List<Project> projects,
  DateTime now,
) {
  final (start, end) = insightsRange(period, now);
  final (heading, labels) = switch (period) {
    InsightsPeriod.day => (
      'Activity by time of day',
      const ['00', '04', '08', '12', '16', '20'],
    ),
    InsightsPeriod.week => (
      'Activity by day',
      const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
    ),
    InsightsPeriod.month => (
      'Activity by week',
      [
        for (var w = 0; w * 7 < end.difference(start).inDays + 0; w++)
          'W${w + 1}',
      ],
    ),
  };

  int bucketOf(DateTime time) => switch (period) {
    InsightsPeriod.day => time.hour ~/ 4,
    InsightsPeriod.week => startOfDay(time).difference(start).inDays,
    InsightsPeriod.month => (time.day - 1) ~/ 7,
  };

  final usage = List<double>.filled(labels.length, 0);
  final attributed = List<double>.filled(labels.length, 0);
  final byProject = <String, Duration>{};
  var unassigned = Duration.zero;
  final assistants = <String, Duration>{};
  final apps = <String, Duration>{};

  for (final activity in activities) {
    final duration = activity.duration;
    if (activity.isPrivate || duration == null) continue;
    final bucket = bucketOf(activity.start);
    if (bucket < 0 || bucket >= labels.length) continue;

    final hours = duration.inSeconds / 3600;
    usage[bucket] += hours;
    final project = matchProject(activity, projects);
    if (project == null) {
      unassigned += duration;
    } else {
      attributed[bucket] += hours;
      byProject.update(
        project.id,
        (time) => time + duration,
        ifAbsent: () => duration,
      );
    }
    if (activity.category == ActivityCategory.ai) {
      assistants.update(
        activity.title.split(' · ').first,
        (time) => time + duration,
        ifAbsent: () => duration,
      );
    }
    if (activity.kind == ActivityKind.appUsage) {
      apps.update(
        activity.title,
        (time) => time + duration,
        ifAbsent: () => duration,
      );
    }
  }

  final rows = [
    for (final project in projects)
      if (byProject[project.id] != null)
        ProjectTime(project.name, byProject[project.id]!, project: project),
  ]..sort((a, b) => b.time.compareTo(a.time));

  return InsightsData(
    heading: heading,
    labels: labels,
    usage: usage,
    attributed: attributed,
    projects: [
      ...rows,
      if (unassigned > Duration.zero) ProjectTime('Unassigned', unassigned),
    ],
    assistants: _ranked(assistants),
    topApps: _ranked(apps).take(4).toList(),
  );
}
