import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/domain/enums.dart';
import '../../../core/format/durations.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../../../core/widgets/hour_bars.dart';
import '../domain/project.dart';
import 'project_providers.dart';

const _ruleKinds = [
  (RuleKind.repo, 'Repo'),
  (RuleKind.path, 'Path'),
  (RuleKind.app, 'App'),
  (RuleKind.title, 'Title'),
];

class ProjectDetailScreen extends ConsumerStatefulWidget {
  const ProjectDetailScreen({required this.id, super.key});

  final String id;

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  final _pattern = TextEditingController();
  var _kind = RuleKind.repo;
  var _adding = false;

  @override
  void dispose() {
    _pattern.dispose();
    super.dispose();
  }

  Future<void> _saveRule(Project project) async {
    final value = _pattern.text.trim();
    if (value.isEmpty) return;
    await ref
        .read(projectRepositoryProvider)
        .save(
          project.copyWith(
            rules: [...project.rules, ProjectRuleItem(_kind, value)],
          ),
        );
    _pattern.clear();
    if (mounted) setState(() => _adding = false);
  }

  Future<void> _removeRule(Project project, ProjectRuleItem rule) => ref
      .read(projectRepositoryProvider)
      .save(
        project.copyWith(rules: project.rules.where((r) => r != rule).toList()),
      );

  Future<void> _askDelete(Project project) async {
    final confirmed = await showAppSheet<bool>(
      context,
      (sheet) => SheetBody(
        title: 'Delete ${project.name}?',
        body:
            'Your recorded activity stays. It just won’t belong to this '
            'project any more.',
        actions: [
          DestructiveButton(
            label: 'Delete project',
            onPressed: () => Navigator.pop(sheet, true),
          ),
          TextButton(
            onPressed: () => Navigator.pop(sheet),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    context.pop();
    await ref.read(projectRepositoryProvider).delete(project.id);
  }

  @override
  Widget build(BuildContext context) {
    Project? found;
    for (final candidate in ref.watch(projectsProvider).value ?? <Project>[]) {
      if (candidate.id == widget.id) found = candidate;
    }
    final stats = ref.watch(projectWeekStatsProvider)[widget.id];
    if (found == null || stats == null) {
      return DetailPage(
        children: [
          if (ref.watch(projectsProvider).hasValue)
            const Text('This project no longer exists.'),
        ],
      );
    }
    final project = found;
    final text = Theme.of(context).textTheme;

    return DetailPage(
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
                    formatDuration(stats.week),
                    style: AppText.mono(size: 28, weight: FontWeight.w600),
                  ),
                  const Text('this week', style: AppText.caption),
                ],
              ),
              const SizedBox(height: 16),
              HourBars(
                labels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
                height: 72,
                barWidth: 20,
                series: [BarSeries('Tracked', project.color, stats.dailyHours)],
              ),
              if (stats.breakdown.isNotEmpty) ...[
                const SizedBox(height: 16),
                for (final (label, time) in stats.breakdown)
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
              _Count(stats.commits, 'commits'),
              _Count(stats.pullRequests, 'PRs'),
              _Count(stats.reviews, 'reviews'),
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
        if (project.rules.isEmpty && !_adding)
          const Text(
            'No rules yet. Add one so activity is assigned automatically.',
            style: AppText.caption,
          ),
        for (final rule in project.rules)
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              spacing: 12,
              children: [
                SizedBox(
                  width: 40,
                  child: Text(rule.label, style: AppText.caption),
                ),
                Expanded(
                  child: Text(rule.value, style: AppText.mono(size: 13)),
                ),
                IconButton(
                  tooltip: 'Remove rule',
                  onPressed: () => _removeRule(project, rule),
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.muted,
                  ),
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
                child: DropdownButtonFormField<RuleKind>(
                  initialValue: _kind,
                  dropdownColor: AppColors.surface,
                  items: [
                    for (final (kind, label) in _ruleKinds)
                      DropdownMenuItem(value: kind, child: Text(label)),
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
          child: const Text('View timeline'),
        ),
        const SizedBox(height: 10),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.destructiveText,
          ),
          onPressed: () => _askDelete(project),
          child: const Text('Delete project'),
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
