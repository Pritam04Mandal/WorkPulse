import 'package:flutter/material.dart' show Color;

import '../../../core/domain/enums.dart';
import '../../tracking/domain/usage_models.dart';

const projectColors = <(String, String)>[
  ('Teal', '#3DD6B0'),
  ('Blue', '#6EA8FE'),
  ('Violet', '#B49CFF'),
  ('Amber', '#F0A35E'),
  ('Rose', '#F28FAD'),
  ('Grey', '#8B919A'),
];

Color colorFromHex(String hex) =>
    Color(int.parse('FF${hex.substring(1)}', radix: 16));

class ProjectRuleItem {
  const ProjectRuleItem(this.kind, this.value);

  final RuleKind kind;
  final String value;

  String get label => switch (kind) {
    RuleKind.app => 'App',
    RuleKind.path => 'Path',
    RuleKind.site => 'Site',
    RuleKind.repo => 'Repo',
    RuleKind.title => 'Title',
  };
}

class Project {
  const Project({
    required this.id,
    required this.name,
    required this.colorHex,
    this.repository,
    this.rules = const [],
  });

  final String id;
  final String name;
  final String colorHex;
  final String? repository;
  final List<ProjectRuleItem> rules;

  Color get color => colorFromHex(colorHex);

  Project copyWith({List<ProjectRuleItem>? rules}) => Project(
    id: id,
    name: name,
    colorHex: colorHex,
    repository: repository,
    rules: rules ?? this.rules,
  );
}

/// A project's week, worked out from its matching activity.
class ProjectStats {
  const ProjectStats({
    required this.dailyHours,
    required this.breakdown,
    required this.commits,
    required this.pullRequests,
    required this.reviews,
    required this.sources,
  });

  factory ProjectStats.from(
    Iterable<TrackedActivity> activities,
    DateTime weekStart,
  ) {
    final hours = List<double>.filled(7, 0);
    final byCategory = <ActivityCategory, Duration>{};
    int count(ActivityKind kind) =>
        activities.where((a) => a.kind == kind).length;

    for (final activity in activities) {
      final duration = activity.duration;
      if (duration == null) continue;
      final day = startOfDay(activity.start).difference(weekStart).inDays;
      if (day >= 0 && day < 7) hours[day] += duration.inSeconds / 3600;
      byCategory.update(
        activity.category,
        (time) => time + duration,
        ifAbsent: () => duration,
      );
    }
    return ProjectStats(
      dailyHours: hours,
      breakdown: [
        for (final (category, label) in const [
          (ActivityCategory.coding, 'Coding'),
          (ActivityCategory.ai, 'AI'),
          (ActivityCategory.meetings, 'Meetings'),
          (ActivityCategory.other, 'Other'),
        ])
          if (byCategory[category] != null) (label, byCategory[category]!),
      ],
      commits: count(ActivityKind.commit),
      pullRequests: count(ActivityKind.pullRequest),
      reviews: count(ActivityKind.review),
      sources: activities.map((a) => a.sourceLabel).toSet().join(' · '),
    );
  }

  /// Monday to Sunday.
  final List<double> dailyHours;
  final List<(String, Duration)> breakdown;
  final int commits;
  final int pullRequests;
  final int reviews;
  final String sources;

  Duration get week => Duration(
    seconds: (dailyHours.fold<double>(0, (sum, h) => sum + h) * 3600).round(),
  );
}
