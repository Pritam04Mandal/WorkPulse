import 'package:flutter/material.dart' show Color;

class ProjectRuleItem {
  const ProjectRuleItem(this.kind, this.value);

  final String kind;
  final String value;
}

class ProjectStats {
  const ProjectStats({
    this.dailyHours = const [0, 0, 0, 0, 0, 0, 0],
    this.breakdown = const [],
    this.commits = 0,
    this.pullRequests = 0,
    this.reviews = 0,
  });

  /// Monday to Sunday.
  final List<double> dailyHours;
  final List<(String, Duration)> breakdown;
  final int commits;
  final int pullRequests;
  final int reviews;

  Duration get week => Duration(
    minutes: (dailyHours.fold<double>(0, (sum, h) => sum + h) * 60).round(),
  );
}

class Project {
  const Project({
    required this.id,
    required this.name,
    required this.color,
    this.repository,
    this.sources = 'No sources yet',
    this.badge = 'Created by you',
    this.autoDiscovered = false,
    this.stats = const ProjectStats(),
    this.rules = const [],
  });

  final String id;
  final String name;
  final Color color;
  final String? repository;
  final String sources;
  final String badge;
  final bool autoDiscovered;
  final ProjectStats stats;
  final List<ProjectRuleItem> rules;

  Project copyWith({
    String? name,
    Color? color,
    String? repository,
    List<ProjectRuleItem>? rules,
  }) => Project(
    id: id,
    name: name ?? this.name,
    color: color ?? this.color,
    repository: repository ?? this.repository,
    sources: sources,
    badge: badge,
    autoDiscovered: autoDiscovered,
    stats: stats,
    rules: rules ?? this.rules,
  );
}
