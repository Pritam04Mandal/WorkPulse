import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/format/durations.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../data/sample_timeline.dart';
import '../domain/timeline_entry.dart';

Color entryColor(EntryKind kind) => switch (kind) {
  EntryKind.coding => AppColors.coding,
  EntryKind.meeting => AppColors.meetings,
  EntryKind.ai => AppColors.ai,
  EntryKind.github => AppColors.accent,
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

const _pastDays = [
  (
    sub: 'No tracked time',
    empty:
        'No apps were used for work, or tracking was paused. Weekends often '
        'look like this.',
  ),
  (
    sub: 'Usage Access was off',
    empty:
        'Android didn’t share usage data this day because the permission was '
        'turned off.',
  ),
];

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  var _filter = TimelineFilter.all;
  var _dayOffset = 0;

  String _dayLabel() {
    final day = DateTime.now().subtract(Duration(days: _dayOffset));
    final date = DateFormat('d MMM').format(day);
    return _dayOffset == 0
        ? 'Today, $date'
        : '${DateFormat('EEE').format(day)}, $date';
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(sampleTimelineProvider);
    final past = _dayOffset == 0 ? null : _pastDays[_dayOffset - 1];
    final tracked = entries
        .where((e) => !e.isGap && e.duration != null)
        .fold(Duration.zero, (sum, e) => sum + e.duration!);
    final gaps = entries
        .where((e) => e.isGap)
        .fold(Duration.zero, (sum, e) => sum + e.duration!);
    final daySub =
        past?.sub ??
        '${formatDuration(tracked)} tracked · ${formatDuration(gaps)} gaps';
    final rows = past == null
        ? filterEntries(entries, _filter)
        : const <TimelineEntry>[];

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: TabHeader(title: 'Timeline', trailing: [SampleDataChip()]),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Previous day',
                    color: AppColors.textSecondary,
                    onPressed: _dayOffset < _pastDays.length
                        ? () => setState(() => _dayOffset++)
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Column(
                      spacing: 2,
                      children: [
                        Text(
                          _dayLabel(),
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
                      message:
                          past?.empty ??
                          'Nothing matches this filter on the selected day.',
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      children: [
                        for (final entry in rows) _TimelineRow(entry: entry),
                      ],
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
    final color = entryColor(entry.kind);
    final outlined =
        entry.isInferred || entry.attribution == Attribution.unassigned;
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
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: outlined ? null : color,
        border: outlined ? Border.all(color: color, width: 2) : null,
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry});

  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final amberTag =
        entry.isInferred || entry.attribution == Attribution.unassigned;
    return IntrinsicHeight(
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
                                formatDuration(entry.duration),
                                style: AppText.mono(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Text.rich(
                            TextSpan(
                              style: AppText.caption,
                              children: [
                                TextSpan(text: '${entry.source} · '),
                                TextSpan(
                                  text: entry.tag,
                                  style: amberTag
                                      ? const TextStyle(color: AppColors.amber)
                                      : null,
                                ),
                              ],
                            ),
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
}
