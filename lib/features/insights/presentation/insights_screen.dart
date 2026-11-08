import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/durations.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../../../core/widgets/hour_bars.dart';

enum _Period { day, week, month }

class _PeriodData {
  const _PeriodData(
    this.heading,
    this.range,
    this.labels,
    this.usage,
    this.attributed,
  );

  final String heading;
  final String range;
  final List<String> labels;
  final List<double> usage;
  final List<double> attributed;

  Duration _total(List<double> hours) => Duration(
    minutes: (hours.fold<double>(0, (sum, h) => sum + h) * 60).round(),
  );
  Duration get usageTotal => _total(usage);
  Duration get attributedTotal => _total(attributed);
}

const _periods = {
  _Period.day: _PeriodData(
    'Activity by hour block',
    'Today',
    ['08', '10', '12', '14', '16', '18'],
    [0.6, 1.8, 1.1, 1.4, 0.7, 0.1],
    [0.4, 1.5, 0.7, 1.2, 0.6, 0],
  ),
  _Period.week: _PeriodData(
    'Activity by day',
    'This week',
    ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
    [6.5, 7.2, 5.8, 6.9, 5.4, 1.2, 1.2],
    [5.6, 6.1, 4.4, 5.9, 4.3, 0.4, 1.3],
  ),
  _Period.month: _PeriodData(
    'Activity by week',
    'This month',
    ['W1', 'W2', 'W3', 'W4'],
    [31.5, 36.2, 29.8, 34.2],
    [25.1, 30.4, 24.0, 28.0],
  ),
};

const _projects = [
  ('workpulse-app', Duration(minutes: 1100), AppColors.coding, 'workpulse-app'),
  ('billing-api', Duration(minutes: 365), AppColors.ai, 'billing-api'),
  (
    'Client meetings',
    Duration(minutes: 220),
    AppColors.amber,
    'client-meetings',
  ),
  ('Unassigned', Duration(minutes: 365), AppColors.other, null),
];

const _apps = [
  ('T', 'Microsoft Teams', Duration(minutes: 271)),
  ('Ch', 'Chrome', Duration(minutes: 228)),
  ('GH', 'GitHub', Duration(minutes: 70)),
  ('Sl', 'Slack', Duration(minutes: 52)),
];

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  var _period = _Period.week;

  @override
  Widget build(BuildContext context) {
    final data = _periods[_period]!;
    final text = Theme.of(context).textTheme;
    final longest = _projects
        .map((p) => p.$2.inMinutes)
        .reduce((a, b) => a > b ? a : b);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const TabHeader(title: 'Insights', trailing: [SampleDataChip()]),
            const SizedBox(height: 8),
            SegmentedTabs(
              options: const [
                (_Period.day, 'Day'),
                (_Period.week, 'Week'),
                (_Period.month, 'Month'),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(data.heading, style: text.titleMedium),
                      ),
                      Text(data.range, style: AppText.caption),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _Legend(
                    color: AppColors.other,
                    label: 'Active app usage',
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
                  const Text(
                    'App usage counts foreground time only. Attributed time is '
                    'usage linked to a project by a repository, a rule or you.',
                    style: AppText.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionTitle('By project'),
            for (final (name, time, color, id) in _projects)
              InkWell(
                onTap: id == null
                    ? () => context.go('/timeline')
                    : () => context.push('/projects/$id'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 6,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(name, style: text.bodySmall)),
                          Text(
                            formatDuration(time),
                            style: AppText.mono(size: 13),
                          ),
                        ],
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: time.inMinutes / longest,
                          minHeight: 6,
                          color: color,
                          backgroundColor: AppColors.divider,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  Expanded(child: _AiCard()),
                  Expanded(child: _MeetingsCard()),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionTitle('Top phone apps'),
            for (final (initials, name, time) in _apps)
              SizedBox(
                height: 48,
                child: Row(
                  spacing: 12,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(initials, style: AppText.mono(size: 11)),
                    ),
                    Expanded(child: Text(name, style: text.bodyMedium)),
                    Text(formatDuration(time), style: AppText.mono(size: 13)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
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

class _AiCard extends StatelessWidget {
  const _AiCard();

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        const Text('AI assistants', style: AppText.caption),
        for (final (name, time) in const [
          ('Claude', Duration(minutes: 185)),
          ('ChatGPT', Duration(minutes: 130)),
        ])
          Row(
            children: [
              Expanded(child: Text(name, style: const TextStyle(fontSize: 13))),
              Text(formatDuration(time), style: AppText.mono()),
            ],
          ),
        const Text('Session time only', style: AppText.caption),
      ],
    ),
  );
}

class _MeetingsCard extends StatelessWidget {
  const _MeetingsCard();

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        const Text('Meetings', style: AppText.caption),
        Text(
          formatDuration(const Duration(minutes: 265)),
          style: AppText.mono(size: 20, weight: FontWeight.w600),
        ),
        const Text('6 meetings', style: TextStyle(fontSize: 13)),
        const Text('Teams calendar', style: AppText.caption),
      ],
    ),
  );
}
