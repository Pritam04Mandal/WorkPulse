import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/durations.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../../../core/widgets/hour_bars.dart';
import '../../projects/domain/project.dart';
import '../../projects/presentation/project_providers.dart';
import '../../tracking/domain/usage_models.dart';
import '../../tracking/presentation/tracking_controller.dart';
import '../domain/insights_data.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  var _period = InsightsPeriod.week;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final activities =
        ref.watch(rangeActivitiesProvider(insightsRange(_period, now))).value ??
        const <TrackedActivity>[];
    final projects = ref.watch(projectsProvider).value ?? const <Project>[];
    final data = buildInsights(_period, activities, projects, now);
    final text = Theme.of(context).textTheme;
    final longest = data.projects.fold(
      1,
      (max, p) => p.time.inMinutes > max ? p.time.inMinutes : max,
    );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const TabHeader(title: 'Insights'),
            const SizedBox(height: 8),
            SegmentedTabs(
              options: const [
                (InsightsPeriod.day, 'Day'),
                (InsightsPeriod.week, 'Week'),
                (InsightsPeriod.month, 'Month'),
              ],
              value: _period,
              onChanged: (period) => setState(() => _period = period),
            ),
            const SizedBox(height: 16),
            AppCard(
              color: AppColors.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(data.heading, style: text.titleMedium),
                  const SizedBox(height: 12),
                  _Legend(
                    color: AppColors.other,
                    label: 'Active usage',
                    total: data.usageTotal,
                  ),
                  const SizedBox(height: 6),
                  _Legend(
                    color: AppColors.accent,
                    label: 'Attributed to projects',
                    total: data.attributedTotal,
                  ),
                  const SizedBox(height: 16),
                  HourBars(
                    labels: data.labels,
                    series: [
                      BarSeries('Active', AppColors.other, data.usage),
                      BarSeries(
                        'Attributed',
                        AppColors.accent,
                        data.attributed,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data.isEmpty
                        ? 'Nothing recorded for this period yet.'
                        : 'Attributed time is usage linked to a project by a '
                              'repository or a rule.',
                    style: AppText.caption,
                  ),
                ],
              ),
            ),
            if (data.projects.isNotEmpty) ...[
              const SizedBox(height: 20),
              const SectionTitle('By project'),
              for (final row in data.projects)
                InkWell(
                  onTap: row.project == null
                      ? () => context.go('/timeline')
                      : () => context.push('/projects/${row.project!.id}'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 6,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(row.name, style: text.bodySmall),
                            ),
                            Text(
                              formatDuration(row.time),
                              style: AppText.mono(size: 13),
                            ),
                          ],
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: row.time.inMinutes / longest,
                            minHeight: 6,
                            color: row.project?.color ?? AppColors.other,
                            backgroundColor: AppColors.divider,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
            if (data.assistants.isNotEmpty) ...[
              const SizedBox(height: 20),
              const SectionTitle('AI assistants'),
              for (final (name, time) in data.assistants)
                _TimeRow(name: name, time: time),
            ],
            if (data.topApps.isNotEmpty) ...[
              const SizedBox(height: 20),
              const SectionTitle('Top phone apps'),
              for (final (name, time) in data.topApps)
                _TimeRow(name: name, time: time, showInitials: true),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.name,
    required this.time,
    this.showInitials = false,
  });

  final String name;
  final Duration time;
  final bool showInitials;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: Row(
      spacing: 12,
      children: [
        if (showInitials)
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              name.characters.take(2).toString(),
              style: AppText.mono(size: 11),
            ),
          ),
        Expanded(
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(formatDuration(time), style: AppText.mono(size: 13)),
      ],
    ),
  );
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.color,
    required this.label,
    required this.total,
  });

  final Color color;
  final String label;
  final Duration total;

  @override
  Widget build(BuildContext context) => Row(
    spacing: 6,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      Expanded(
        child: Text(
          label,
          style: AppText.caption.copyWith(color: AppColors.textSecondary),
        ),
      ),
      Text(formatDuration(total), style: AppText.mono(size: 13)),
    ],
  );
}
