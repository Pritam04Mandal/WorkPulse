import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/durations.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../../../core/widgets/hour_bars.dart';
import '../data/sample_projects.dart';
import '../domain/project.dart';

const _ruleKinds = ['App', 'Path', 'Site', 'Repo'];

class ProjectDetailScreen extends ConsumerStatefulWidget {
  const ProjectDetailScreen({required this.id, super.key});

  final String id;

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  final _pattern = TextEditingController();
  var _kind = _ruleKinds.first;
  var _adding = false;

  @override
  void dispose() {
    _pattern.dispose();
    super.dispose();
  }

  void _saveRule(Project project) {
    final value = _pattern.text.trim();
    if (value.isEmpty) return;
    ref
        .read(sampleProjectsProvider.notifier)
        .upsert(
          project.copyWith(
            rules: [...project.rules, ProjectRuleItem(_kind, value)],
          ),
        );
    _pattern.clear();
    setState(() => _adding = false);
  }

  @override
  Widget build(BuildContext context) {
    Project? found;
    for (final candidate in ref.watch(sampleProjectsProvider)) {
      if (candidate.id == widget.id) found = candidate;
    }
    if (found == null) {
      return const DetailPage(
        sample: true,
        children: [Text('This project no longer exists.')],
      );
    }
    final project = found;
    final text = Theme.of(context).textTheme;

    return DetailPage(
      sample: true,
      actions: [
        IconButton(
          tooltip: 'Edit project',
          onPressed: () => context.push('/projects/${project.id}/edit'),
          icon: const Icon(Icons.edit_outlined, size: 20),
        ),
      ],
      children: [
        Row(
          spacing: 10,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: project.color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Expanded(child: Text(project.name, style: text.headlineSmall)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          project.repository ?? 'No repository',
          style: AppText.mono(size: 13, color: AppColors.muted),
        ),
        const SizedBox(height: 20),
        AppCard(
          color: AppColors.surface,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                spacing: 8,
                children: [
                  Text(
                    formatDuration(project.stats.week),
                    style: AppText.mono(size: 28, weight: FontWeight.w600),
                  ),
                  const Text('this week · sample', style: AppText.caption),
                ],
              ),
              const SizedBox(height: 16),
              HourBars(
                labels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
                height: 72,
                barWidth: 20,
                series: [
                  BarSeries('Tracked', project.color, project.stats.dailyHours),
                ],
              ),
              if (project.stats.breakdown.isNotEmpty) ...[
                const SizedBox(height: 16),
                for (final (label, time) in project.stats.breakdown)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: text.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Text(
                          formatDuration(time),
                          style: AppText.mono(size: 13),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
        if (project.repository != null) ...[
          const SizedBox(height: 20),
          const SectionTitle('GitHub this week'),
          Row(
            children: [
              _Count(project.stats.commits, 'commits'),
              _Count(project.stats.pullRequests, 'PRs'),
              _Count(project.stats.reviews, 'reviews'),
            ],
          ),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: Text('Matching rules', style: text.titleMedium)),
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(64, 40),
                foregroundColor: AppColors.accent,
              ),
              onPressed: () => setState(() => _adding = !_adding),
              child: Text(_adding ? 'Cancel' : 'Add rule'),
            ),
          ],
        ),
        for (final rule in project.rules)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              spacing: 12,
              children: [
                SizedBox(
                  width: 40,
                  child: Text(rule.kind, style: AppText.caption),
                ),
                Expanded(
                  child: Text(rule.value, style: AppText.mono(size: 13)),
                ),
              ],
            ),
          ),
        if (_adding) ...[
          const SizedBox(height: 12),
          Row(
            spacing: 10,
            children: [
              SizedBox(
                width: 100,
                child: DropdownButtonFormField<String>(
                  initialValue: _kind,
                  dropdownColor: AppColors.surface,
                  items: [
                    for (final kind in _ruleKinds)
                      DropdownMenuItem(value: kind, child: Text(kind)),
                  ],
                  onChanged: (kind) => setState(() => _kind = kind ?? _kind),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _pattern,
                  decoration: const InputDecoration(hintText: 'Matches'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () => _saveRule(project),
            child: const Text('Save rule'),
          ),
        ],
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => context.go('/timeline'),
          child: const Text('View project timeline'),
        ),
      ],
    );
  }
}

class _Count extends StatelessWidget {
  const _Count(this.value, this.label);

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$value ',
            style: AppText.mono(size: 18, weight: FontWeight.w600),
          ),
          TextSpan(text: label, style: AppText.caption),
        ],
      ),
    ),
  );
}
