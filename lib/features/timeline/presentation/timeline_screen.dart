import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/format/durations.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../../tracking/domain/usage_models.dart';
import '../../companion/presentation/companion_controller.dart';
import '../../tracking/presentation/tracking_controller.dart';
import '../domain/timeline_builder.dart';
import '../domain/timeline_entry.dart';

Color entryColor(EntryKind kind) => switch (kind) {
  EntryKind.coding => AppColors.coding,
  EntryKind.meeting => AppColors.meetings,
  EntryKind.ai => AppColors.ai,
  EntryKind.github => AppColors.accent,
  EntryKind.other => AppColors.muted,
  EntryKind.private => AppColors.other,
  EntryKind.gap => AppColors.borderStrong,
};

const _filters = [
  (TimelineFilter.all, 'All'),
  (TimelineFilter.coding, 'Coding'),
  (TimelineFilter.meeting, 'Meetings'),
  (TimelineFilter.ai, 'AI'),
  (TimelineFilter.github, 'GitHub'),
];

const _maxDaysBack = 30;

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  var _filter = TimelineFilter.all;
  var _dayOffset = 0;
  var _hasLive = false;
  late final Timer _clock;

  @override
  void initState() {
    super.initState();
    // Only redraws while a session is running, so the timers can tick.
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_hasLive && mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clock.cancel();
    super.dispose();
  }

  String _dayLabel(DateTime day) {
    final date = DateFormat('d MMM').format(day);
    return _dayOffset == 0
        ? 'Today, $date'
        : '${DateFormat('EEE').format(day)}, $date';
  }

  String _emptyMessage(TrackingState tracking, bool hasEntries) {
    if (hasEntries) return 'Nothing matches this filter on the selected day.';
    if (_dayOffset == 0 && !tracking.usageGranted) {
      return 'Android isn’t sharing usage data because the permission is off.';
    }
    if (_dayOffset == 0 && tracking.privateSession) {
      return 'A private session is on, so nothing is being recorded.';
    }
    return 'No apps were recorded on this day, or tracking was paused.';
  }

  @override
  Widget build(BuildContext context) {
    final tracking = ref.watch(trackingControllerProvider);
    final today = startOfDay(DateTime.now());
    final day = DateTime(today.year, today.month, today.day - _dayOffset);
    final activities = ref.watch(dayActivitiesProvider(day)).value ?? const [];
    final entries = buildTimelineEntries(
      activities,
      liveIds: ref.watch(liveSessionsProvider),
    );
    _hasLive = entries.any((e) => e.isLive);
    final rows = filterEntries(entries, _filter);
    final daySub = entries.isEmpty
        ? 'No tracked time'
        : '${formatDuration(trackedTime(entries))} tracked · '
              '${formatDuration(gapTime(entries))} gaps';

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: TabHeader(title: 'Timeline'),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Previous day',
                    color: AppColors.textSecondary,
                    onPressed: _dayOffset < _maxDaysBack
                        ? () => setState(() => _dayOffset++)
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Column(
                      spacing: 2,
                      children: [
                        Text(
                          _dayLabel(day),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          daySub,
                          style: AppText.mono(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next day',
                    color: AppColors.textSecondary,
                    onPressed: _dayOffset > 0
                        ? () => setState(() => _dayOffset--)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  for (final (filter, label) in _filters)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: PillButton(
                        label: label,
                        selected: filter == _filter,
                        onTap: () => setState(() => _filter = filter),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: rows.isEmpty
                  ? _EmptyDay(
                      message: _emptyMessage(tracking, entries.isNotEmpty),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      itemCount: rows.length,
                      itemBuilder: (context, index) =>
                          _TimelineRow(entry: rows[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(32, 56, 32, 0),
    child: Column(
      spacing: 12,
      children: [
        const Icon(Icons.schedule, size: 40, color: AppColors.other),
        Text(
          'Nothing recorded',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontSize: 16),
        ),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppText.caption.copyWith(fontSize: 13),
        ),
        TextButton(
          onPressed: () => context.go('/settings'),
          child: const Text(
            'Check tracking settings',
            style: TextStyle(color: AppColors.accent, fontSize: 14),
          ),
        ),
      ],
    ),
  );
}

class _Dot extends StatelessWidget {
  const _Dot({required this.entry});

  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    if (entry.isGap) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.other),
        ),
      );
    }
    final color = entryColor(entry.kind);
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: entry.isInferred ? null : color,
        border: entry.isInferred ? Border.all(color: color, width: 2) : null,
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry});

  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 44,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(
              clockLabel(entry.start),
              style: AppText.mono(color: AppColors.muted),
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 16,
          child: Column(
            children: [
              Container(width: 2, height: 14, color: AppColors.border),
              _Dot(entry: entry),
              Expanded(child: Container(width: 2, color: AppColors.border)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: entry.isGap
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 0, 14),
                  child: Text(
                    entry.displayTitle,
                    style: AppText.caption.copyWith(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: AppCard(
                    color: AppColors.surface,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    onTap: () => context.push('/activity/${entry.id}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 6,
                      children: [
                        Row(
                          spacing: 8,
                          children: [
                            Expanded(
                              child: Text(
                                entry.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              entry.isLive
                                  ? formatElapsed(entry.duration!)
                                  : formatDuration(entry.duration),
                              style: AppText.mono(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${entry.source} · ${entry.tag}',
                          style: entry.isLive
                              ? AppText.caption.copyWith(
                                  color: AppColors.accent,
                                )
                              : AppText.caption,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    ),
  );
}
