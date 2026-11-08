import 'package:flutter/material.dart' show Color;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/tokens.dart';
import '../domain/project.dart';

const projectColors = <(String, Color)>[
  ('Teal', AppColors.accent),
  ('Blue', AppColors.coding),
  ('Violet', AppColors.ai),
  ('Amber', AppColors.amber),
  ('Rose', Color(0xFFF28FAD)),
  ('Grey', AppColors.muted),
];

const _sampleProjects = [
  Project(
    id: 'workpulse-app',
    name: 'workpulse-app',
    color: AppColors.coding,
    repository: 'github.com/sample/workpulse-app',
    sources: 'GitHub · VS Code · Claude',
    badge: 'From repository',
    stats: ProjectStats(
      dailyHours: [3.2, 4.4, 2.9, 4.1, 3.0, 0.233, 0.5],
      breakdown: [
        ('Coding', Duration(minutes: 890)),
        ('AI', Duration(minutes: 155)),
        ('Meetings', Duration(minutes: 55)),
      ],
      commits: 23,
      pullRequests: 4,
      reviews: 3,
    ),
    rules: [
      ProjectRuleItem('Repo', 'github.com/sample/workpulse-app'),
      ProjectRuleItem('Path', '~/code/workpulse-app/**'),
      ProjectRuleItem('Site', 'claude.ai · when you tag it'),
    ],
  ),
  Project(
    id: 'billing-api',
    name: 'billing-api',
    color: AppColors.ai,
    repository: 'github.com/sample/billing-api',
    sources: 'GitHub · ChatGPT',
    badge: 'From repository',
    stats: ProjectStats(
      dailyHours: [1.6, 0.8, 2.0, 0.4, 1.28, 0, 0],
      breakdown: [
        ('Coding', Duration(minutes: 290)),
        ('AI', Duration(minutes: 75)),
      ],
      commits: 6,
      pullRequests: 1,
      reviews: 1,
    ),
    rules: [ProjectRuleItem('Repo', 'github.com/sample/billing-api')],
  ),
  Project(
    id: 'client-meetings',
    name: 'Client meetings',
    color: AppColors.amber,
    sources: 'Teams calendar',
    badge: 'Auto-discovered · 74%',
    autoDiscovered: true,
    stats: ProjectStats(
      dailyHours: [0.8, 1.3, 0, 0.87, 0.7, 0, 0],
      breakdown: [('Meetings', Duration(minutes: 220))],
    ),
    rules: [ProjectRuleItem('Title', 'Client')],
  ),
];

/// Sample projects. Additions and edits last until the app restarts.
class SampleProjects extends Notifier<List<Project>> {
  @override
  List<Project> build() => _sampleProjects;

  void upsert(Project project) {
    final exists = state.any((p) => p.id == project.id);
    state = exists
        ? [
            for (final p in state)
              if (p.id == project.id) project else p,
          ]
        : [...state, project];
  }
}

final sampleProjectsProvider = NotifierProvider<SampleProjects, List<Project>>(
  SampleProjects.new,
);
