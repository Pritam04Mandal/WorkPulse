import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/durations.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../../tracking/domain/usage_models.dart';
import '../../tracking/presentation/tracking_controller.dart';
import '../domain/project.dart';
import '../domain/project_matcher.dart';
import 'project_providers.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider).value ?? const <Project>[];
    final stats = ref.watch(projectWeekStatsProvider);
    final today =
        ref.watch(dayActivitiesProvider(startOfDay(DateTime.now()))).value ??
        const <TrackedActivity>[];
    final unassigned = today
        .where((a) => !a.isPrivate && a.duration != null)
        .where((a) => matchProject(a, projects) == null)
        .toList();
    final unassignedTime = unassigned.fold(
      Duration.zero,
      (sum, a) => sum + a.duration!,
    );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            TabHeader(
              title: 'Projects',
              trailing: [
                IconButton(
                  tooltip: 'New project',
                  onPressed: () => context.push('/projects/new'),
                  icon: const Icon(Icons.add, color: AppColors.text),
                ),
              ],
            ),
            if (projects.isNotEmpty)
              Text(
                'This week · ${projects.length} active',
                style: AppText.caption.copyWith(fontSize: 13),
              ),
            const SizedBox(height: 14),
            if (projects.isNotEmpty && unassigned.isNotEmpty) ...[
              _UnassignedBanner(time: unassignedTime, count: unassigned.length),
              const SizedBox(height: 14),
            ],
            for (final project in projects) ...[
              if (stats[project.id] case final ProjectStats projectStats)
                _ProjectCard(project: project, stats: projectStats),
              const SizedBox(height: 12),
            ],
            if (projects.every((p) => p.isDefault)) const _EmptyProjects(),
          ],
        ),
      ),
    );
  }
}

class _EmptyProjects extends StatelessWidget {
  const _EmptyProjects();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 32),
    child: Column(
      spacing: 12,
      children: [
        const Icon(Icons.folder_outlined, size: 40, color: AppColors.other),
        Text(
          'No projects of your own yet',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontSize: 16),
        ),
        Text(
          'Create one and link a repository or folder. Matching activity is '
          'added to it automatically.',
          textAlign: TextAlign.center,
          style: AppText.caption.copyWith(fontSize: 13),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(180, 48)),
          onPressed: () => context.push('/projects/new'),
          child: const Text('New project'),
        ),
      ],
    ),
  );
}

class _UnassignedBanner extends StatelessWidget {
  const _UnassignedBanner({required this.time, required this.count});

  final Duration time;
  final int count;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.amberTint,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.amberBorder),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => context.go('/timeline'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${formatDuration(time)} unassigned today',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$count ${count == 1 ? 'event matches' : 'events match'} '
                    'no project',
                    style: AppText.caption,
                  ),
                ],
              ),
            ),
            const Text(
              'Review',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.amber,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project, required this.stats});

  final Project project;
  final ProjectStats stats;

  @override
  Widget build(BuildContext context) {
    final peak = stats.dailyHours.fold<double>(0.01, (m, h) => h > m ? h : m);
    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: () => context.push('/projects/${project.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Row(
            spacing: 8,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: project.color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Expanded(
                child: Text(
                  project.name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                formatDuration(stats.week),
                style: AppText.mono(size: 14, weight: FontWeight.w500),
              ),
            ],
          ),
          Text(
            project.isDefault
                ? 'System apps'
                : switch (project.repositories) {
                    [] => 'No repository',
                    [final only] => only,
                    [final first, ...final rest] =>
                      '$first +${rest.length} more',
                  },
            style: AppText.mono(color: AppColors.muted),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(
            height: 28,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 4,
              children: [
                for (final h in stats.dailyHours)
                  Expanded(
                    child: Container(
                      height: (h / peak * 28).clamp(3, 28),
                      decoration: BoxDecoration(
                        color: h > 0 ? project.color : AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            stats.sources.isEmpty ? 'No activity this week' : stats.sources,
            overflow: TextOverflow.ellipsis,
            style: AppText.caption,
          ),
        ],
      ),
    );
  }
}
