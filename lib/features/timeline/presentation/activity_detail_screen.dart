import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/durations.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../../tracking/domain/usage_models.dart';
import '../../tracking/presentation/tracking_controller.dart';
import '../domain/timeline_builder.dart';
import '../domain/timeline_entry.dart';
import 'timeline_screen.dart';

class ActivityDetailScreen extends ConsumerWidget {
  const ActivityDetailScreen({required this.id, super.key});

  final String id;

  Future<void> _editTimes(
    BuildContext context,
    WidgetRef ref,
    TrackedActivity activity,
  ) async {
    final start = await showTimePicker(
      context: context,
      helpText: 'Start time',
      initialTime: TimeOfDay.fromDateTime(activity.start),
    );
    if (start == null || !context.mounted) return;
    final end = await showTimePicker(
      context: context,
      helpText: 'End time',
      initialTime: TimeOfDay.fromDateTime(activity.end!),
    );
    if (end == null || !context.mounted) return;
    if (minutesOf(end) <= minutesOf(start)) {
      showToast(context, 'End time must be after the start time.');
      return;
    }
    final day = startOfDay(activity.start);
    await ref
        .read(trackingRepositoryProvider)
        .correctTimes(
          activity.id,
          day.add(Duration(minutes: minutesOf(start))),
          day.add(Duration(minutes: minutesOf(end))),
        );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    TrackedActivity activity,
  ) async {
    final confirmed = await showAppSheet<bool>(
      context,
      (sheet) => SheetBody(
        title: 'Delete this event?',
        body: 'It’s removed from this phone and won’t be imported again.',
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
    if (confirmed != true || !context.mounted) return;
    context.pop();
    await ref.read(trackingRepositoryProvider).deleteActivity(activity.id);
  }

  String _timeRange(TrackedActivity activity) {
    final start = clockLabel(TimeOfDay.fromDateTime(activity.start));
    if (activity.end == null) return start;
    final end = clockLabel(TimeOfDay.fromDateTime(activity.end!));
    final corrected = activity.isCorrected ? ' · corrected' : '';
    return '$start – $end · ${formatDuration(activity.duration)}$corrected';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(activityProvider(id));
    final activity = async.value;
    if (activity == null) {
      return DetailPage(
        children: [
          if (!async.isLoading) const Text('This event no longer exists.'),
        ],
      );
    }

    final text = Theme.of(context).textTheme;
    final repository = ref.read(trackingRepositoryProvider);
    final kind = entryKindFor(activity);
    final hidden = activity.isPrivate;
    final categoryLabel = switch (kind) {
      EntryKind.coding => 'Coding',
      EntryKind.meeting => 'Meeting',
      EntryKind.ai => 'AI assistant',
      EntryKind.github => 'GitHub',
      EntryKind.private => 'Private',
      _ => 'App',
    };

    return DetailPage(
      children: [
        Row(
          spacing: 8,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: entryColor(kind),
                shape: BoxShape.circle,
              ),
            ),
            Text(categoryLabel, style: AppText.caption.copyWith(fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          hidden ? 'Private session' : activity.title,
          style: text.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          _timeRange(activity),
          style: AppText.mono(size: 13, color: AppColors.textSecondary),
        ),
        if (hidden) ...[
          const SizedBox(height: 8),
          Text(
            'Private · hidden from reports',
            style: AppText.caption.copyWith(color: AppColors.amber),
          ),
        ],
        const SizedBox(height: 20),
        if (!hidden) ...[
          KeyValueList(
            rows: [
              ('Source', activity.sourceLabel, false),
              if (activity.application != null)
                ('Application', activity.application!, true),
              ('Project', 'No project', false),
              if (activity.mergedEvents > 1)
                ('Merged from', '${activity.mergedEvents} focus events', false),
              (
                'Recorded',
                activity.isCorrected
                    ? 'Corrected by you'
                    : 'Observed start and end',
                false,
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (activity.end != null) ...[
            OutlinedButton(
              onPressed: () => _editTimes(context, ref, activity),
              child: const Text('Edit times'),
            ),
            const SizedBox(height: 10),
          ],
        ],
        OutlinedButton(
          onPressed: () => repository.setActivityPrivate(activity.id, !hidden),
          child: Text(hidden ? 'Remove private mark' : 'Mark as private'),
        ),
        const SizedBox(height: 10),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.destructiveText,
          ),
          onPressed: () => _delete(context, ref, activity),
          child: const Text('Delete event'),
        ),
      ],
    );
  }
}
