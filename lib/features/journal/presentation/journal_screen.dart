import 'package:flutter/material.dart';

import '../../../core/format/durations.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/detail_widgets.dart';

const _dayProjects = [
  ('workpulse-app', Duration(minutes: 184)),
  ('billing-api', Duration(minutes: 58)),
  ('Unassigned', Duration(minutes: 72)),
];

const _dayGitHub = [
  '4 commits to workpulse-app, incl. "Add drift migrations"',
  'Opened PR #42, merged PR #39',
  'Reviewed PR #17 on billing-api',
];

const _dayMeetings = [
  ('Sprint planning', Duration(minutes: 45)),
  ('Design sync', Duration(minutes: 20)),
];

const _dayCoding =
    '2h 51m of editor time across 3 sessions. 5 AI assistant sessions '
    '(1h 06m), 3 tagged to workpulse-app.';

const _weekHighlights = [
  'workpulse-app: 23 commits, 4 PRs (3 merged)',
  'billing-api: 6h 05m, 1 review',
  '6 meetings, 4h 25m in total',
  'Busiest day: Tuesday, 7h 12m',
];

const _disclaimer =
    'Built only from recorded events. Time is observed activity, not proof of '
    'output.';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  var _weekly = false;

  /// The plain-text form of the visible report. Sample content for now.
  String _reportText() {
    final lines = _weekly
        ? [
            'Week of 2 November (sample data)',
            'Tracked 34h 10m, attributed 28h 05m',
            ..._weekHighlights.map((h) => '- $h'),
          ]
        : [
            'Sunday, 8 November (sample data)',
            for (final (name, time) in _dayProjects)
              '$name: ${formatDuration(time)}',
            ..._dayGitHub.map((g) => '- $g'),
            for (final (name, time) in _dayMeetings)
              '$name: ${formatDuration(time)}',
            _dayCoding,
          ];
    return [...lines, _disclaimer].join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return DetailPage(
      sample: true,
      footer: [
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => copyToClipboard(
                  context,
                  _reportText(),
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
        Text(
          _weekly ? 'Week of 2 November' : 'Sunday, 8 November',
          style: text.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          _weekly
              ? 'Rule-based · from 1,842 events across 3 sources'
              : 'Rule-based · from 312 events · 5h 42m tracked',
          style: AppText.caption,
        ),
        const SizedBox(height: 16),
        if (_weekly) ...[
          const _Section(
            children: [
              _ValueRow('Tracked', Duration(minutes: 2050)),
              _ValueRow('Attributed', Duration(minutes: 1685)),
            ],
          ),
          _Section(
            title: 'Highlights',
            children: [for (final h in _weekHighlights) _Bullet(h)],
          ),
        ] else ...[
          _Section(
            title: 'Main projects',
            children: [
              for (final (name, time) in _dayProjects) _ValueRow(name, time),
            ],
          ),
          _Section(
            title: 'GitHub',
            children: [for (final g in _dayGitHub) _Bullet(g)],
          ),
          _Section(
            title: 'Meetings',
            children: [
              for (final (name, time) in _dayMeetings) _ValueRow(name, time),
            ],
          ),
          _Section(
            title: 'Coding & AI',
            children: [
              Text(
                _dayCoding,
                style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
        const Text(_disclaimer, style: AppText.caption),
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

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    '–  $text',
    style: Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: AppColors.textSecondary),
  );
}
