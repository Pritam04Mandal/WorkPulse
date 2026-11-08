import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/durations.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../../projects/domain/project.dart';
import '../../projects/presentation/project_providers.dart';
import '../../tracking/domain/usage_models.dart';
import '../../tracking/presentation/tracking_controller.dart';
import '../domain/journal_report.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  var _weekly = false;

  JournalReport _report() {
    final now = DateTime.now();
    final projects = ref.watch(projectsProvider).value ?? const <Project>[];
    if (_weekly) {
      final range = currentWeekRange();
      return buildWeeklyReport(
        ref.watch(rangeActivitiesProvider(range)).value ?? const [],
        projects,
        range.$1,
      );
    }
    final today = startOfDay(now);
    return buildDailyReport(
      ref.watch(dayActivitiesProvider(today)).value ?? const [],
      projects,
      today,
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = _report();
    final text = Theme.of(context).textTheme;
    final body = text.bodySmall?.copyWith(color: AppColors.textSecondary);

    return DetailPage(
      footer: [
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: report.isEmpty
                    ? null
                    : () => copyToClipboard(
                        context,
                        report.toPlainText(),
                        'Report copied as plain text',
                      ),
                child: const Text('Copy'),
              ),
            ),
            Expanded(
              child: OutlinedButton(
                onPressed: () => showToast(context, notAvailableYet),
                child: const Text('CSV'),
              ),
            ),
            Expanded(
              child: OutlinedButton(
                onPressed: () => showToast(context, notAvailableYet),
                child: const Text('PDF'),
              ),
            ),
          ],
        ),
      ],
      children: [
        SegmentedTabs(
          options: const [(false, 'Daily'), (true, 'Weekly')],
          value: _weekly,
          onChanged: (weekly) => setState(() => _weekly = weekly),
        ),
        const SizedBox(height: 16),
        Text(report.heading, style: text.headlineSmall),
        const SizedBox(height: 4),
        Text(report.basis, style: AppText.caption),
        const SizedBox(height: 16),
        if (report.tracked != null && !report.isEmpty)
          _Section(
            children: [
              _ValueRow('Tracked', report.tracked!),
              _ValueRow('Attributed', report.attributed!),
            ],
          ),
        if (report.projects.isNotEmpty)
          _Section(
            title: 'Main projects',
            children: [
              for (final (name, time) in report.projects) _ValueRow(name, time),
            ],
          ),
        if (report.github.isNotEmpty)
          _Section(
            title: 'GitHub',
            children: [
              for (final line in report.github) Text('–  $line', style: body),
            ],
          ),
        if (report.highlights.isNotEmpty)
          _Section(
            title: 'Highlights',
            children: [
              for (final line in report.highlights)
                Text('–  $line', style: body),
            ],
          ),
        if (report.codingSummary != null)
          _Section(
            title: 'Coding & AI',
            children: [Text(report.codingSummary!, style: body)],
          ),
        const Text(journalDisclaimer, style: AppText.caption),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.children, this.title});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [if (title != null) SectionTitle(title!), ...children],
      ),
    ),
  );
}

class _ValueRow extends StatelessWidget {
  const _ValueRow(this.label, this.time);

  final String label;
  final Duration time;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
      ),
      Text(formatDuration(time), style: AppText.mono(size: 13)),
    ],
  );
}
