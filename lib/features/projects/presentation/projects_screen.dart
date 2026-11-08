import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/durations.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../data/sample_projects.dart';
import '../domain/project.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(sampleProjectsProvider);
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    'This week · ${projects.length} active',
                    style: AppText.caption.copyWith(fontSize: 13),
                  ),
                ),
                const SampleDataChip(),
              ],
            ),
            const SizedBox(height: 14),
            Material(
              color: AppColors.amberTint,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.amberBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => context.go('/timeline'),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '1h 12m unassigned today',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '6 events need a project',
                              style: AppText.caption,
                            ),
                          ],
                        ),
                      ),
                      Text(
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
            ),
            const SizedBox(height: 14),
            for (final project in projects) ...[
              _ProjectCard(project: project),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final hours = project.stats.dailyHours;
    final peak = hours.fold<double>(0.01, (m, h) => h > m ? h : m);
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
                formatDuration(project.stats.week),
                style: AppText.mono(size: 14, weight: FontWeight.w500),
              ),
            ],
          ),
          Text(
            project.repository ?? 'No repository',
            style: AppText.mono(color: AppColors.muted),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(
            height: 28,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 4,
              children: [
                for (final h in hours)
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
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: Text(
                  project.sources,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: project.autoDiscovered
                        ? AppColors.borderStrong
                        : AppColors.accentTint,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  project.badge,
                  style: TextStyle(
                    fontSize: 11,
                    color: project.autoDiscovered
                        ? AppColors.muted
                        : AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
