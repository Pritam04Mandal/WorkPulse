import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/durations.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../../projects/data/sample_projects.dart';
import '../data/sample_timeline.dart';
import '../domain/timeline_entry.dart';
import 'timeline_screen.dart';

class ActivityDetailScreen extends ConsumerStatefulWidget {
  const ActivityDetailScreen({required this.id, super.key});

  final String id;

  @override
  ConsumerState<ActivityDetailScreen> createState() =>
      _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends ConsumerState<ActivityDetailScreen> {
  String? _chosenProject;
  bool _resolved = false;
  bool _private = false;
  TimeOfDay? _correctedStart;
  TimeOfDay? _correctedEnd;

  String _badge(TimelineEntry entry) {
    if (_chosenProject != null) return 'Set by you';
    if (_resolved) return 'Confirmed by you';
    return switch (entry.attribution) {
      Attribution.inferred => 'Inferred · ${entry.confidence}%',
      Attribution.setByYou => 'Set by you',
      Attribution.unassigned => 'Unassigned',
      Attribution.hidden => 'Hidden',
      Attribution.observed => 'Observed',
    };
  }

  Future<void> _pickProject() async {
    final names = [
      for (final project in ref.read(sampleProjectsProvider)) project.name,
      'No project',
    ];
    final picked = await showAppSheet<String>(
      context,
      (sheet) => SheetBody(
        title: 'Move to project',
        actions: [
          for (final name in names)
            OutlinedButton(
              onPressed: () => Navigator.pop(sheet, name),
              child: Text(name),
            ),
          TextButton(
            onPressed: () => Navigator.pop(sheet),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (picked != null) {
      setState(() {
        _chosenProject = picked;
        _resolved = true;
      });
    }
  }

  Future<void> _editTimes(TimelineEntry entry) async {
    final start = await showTimePicker(
      context: context,
      helpText: 'Start time',
      initialTime: _correctedStart ?? entry.start,
    );
    if (start == null || !mounted) return;
    final end = await showTimePicker(
      context: context,
      helpText: 'End time',
      initialTime: _correctedEnd ?? entry.end!,
    );
    if (end == null || !mounted) return;
    if (minutesOf(end) <= minutesOf(start)) {
      showToast(context, 'End time must be after the start time.');
      return;
    }
    setState(() {
      _correctedStart = start;
      _correctedEnd = end;
    });
  }

  Future<void> _delete(TimelineEntry entry) async {
    final confirmed = await showAppSheet<bool>(
      context,
      (sheet) => SheetBody(
        title: 'Delete this event?',
        body:
            'It’s removed from this phone and won’t be re-imported from '
            '${entry.source.toLowerCase()}.',
        actions: [
          DestructiveButton(
            label: 'Delete',
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
    ref.read(sampleTimelineProvider.notifier).remove(entry.id);
    context.pop();
  }

  String _timeRange(TimelineEntry entry) {
    final start = _correctedStart ?? entry.start;
    final end = _correctedEnd ?? entry.end;
    if (end == null) return clockLabel(start);
    final corrected = _correctedStart != null ? ' · corrected' : '';
    return '${clockLabel(start)} – ${clockLabel(end)} · '
        '${formatDuration(spanBetween(start, end))}$corrected';
  }

  @override
  Widget build(BuildContext context) {
    TimelineEntry? entry;
    for (final candidate in ref.watch(sampleTimelineProvider)) {
      if (candidate.id == widget.id) entry = candidate;
    }
    if (entry == null) {
      return const DetailPage(
        sample: true,
        children: [Text('This event no longer exists.')],
      );
    }
    final item = entry;
    final hidden = item.attribution == Attribution.hidden;
    final text = Theme.of(context).textTheme;
    final color = entryColor(item.kind);
    final categoryLabel = switch (item.kind) {
      EntryKind.coding => 'Coding',
      EntryKind.meeting => 'Meeting',
      EntryKind.ai => 'AI assistant',
      EntryKind.github => 'GitHub',
      _ => 'Private',
    };
    final project = _chosenProject ?? item.project ?? 'No project';
    final pending =
        !_resolved &&
        (item.isInferred || item.attribution == Attribution.unassigned);
    final badgeColor = pending ? AppColors.amber : AppColors.accent;

    return DetailPage(
      sample: true,
      children: [
        Row(
          spacing: 8,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            Text(categoryLabel, style: AppText.caption.copyWith(fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        Text(item.title, style: text.headlineSmall),
        const SizedBox(height: 4),
        Text(
          _timeRange(item),
          style: AppText.mono(size: 13, color: AppColors.textSecondary),
        ),
        if (_private) ...[
          const SizedBox(height: 8),
          Text(
            'Private · hidden from reports',
            style: AppText.caption.copyWith(color: AppColors.amber),
          ),
        ],
        const SizedBox(height: 20),
        if (!hidden) ...[
          AppCard(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('Project', style: AppText.caption),
                    ),
                    Text(
                      _badge(item),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
                Text(project, style: text.titleMedium),
                if (_resolved)
                  Text(
                    'Future sessions like this go to $project automatically.',
                    style: AppText.caption,
                  )
                else if (item.reason != null)
                  Text(item.reason!, style: AppText.caption),
                if (pending) ...[
                  const SizedBox(height: 4),
                  Row(
                    spacing: 10,
                    children: [
                      if (item.isInferred)
                        Expanded(
                          child: FilledButton(
                            onPressed: () => setState(() => _resolved = true),
                            child: const Text('Confirm'),
                          ),
                        ),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _pickProject,
                          child: const Text('Change project'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          KeyValueList(
            rows: [
              ('Source', item.source, false),
              if (item.application != null)
                ('Application', item.application!, true),
              if (item.workspace != null) ('Workspace', item.workspace!, true),
              if (item.mergedFrom != null)
                ('Merged from', '${item.mergedFrom} focus events', false),
              (
                'Recorded',
                item.end == null ? 'Observed event' : 'Observed start and end',
                false,
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
        if (item.end != null && !hidden)
          OutlinedButton(
            onPressed: () => _editTimes(item),
            child: const Text('Edit times'),
          ),
        if (!hidden) ...[
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => setState(() => _private = !_private),
            child: Text(_private ? 'Remove private mark' : 'Mark as private'),
          ),
          const SizedBox(height: 10),
        ],
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.destructiveText,
          ),
          onPressed: () => _delete(item),
          child: const Text('Delete event'),
        ),
      ],
    );
  }
}
