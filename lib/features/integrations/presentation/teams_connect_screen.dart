import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/detail_widgets.dart';

enum _Phase { intro, waiting, done }

class TeamsConnectScreen extends StatefulWidget {
  const TeamsConnectScreen({super.key});

  @override
  State<TeamsConnectScreen> createState() => _TeamsConnectScreenState();
}

class _TeamsConnectScreenState extends State<TeamsConnectScreen> {
  var _phase = _Phase.intro;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() => _phase = _Phase.waiting);
    _timer = Timer(
      const Duration(milliseconds: 1500),
      () => setState(() => _phase = _Phase.done),
    );
  }

  @override
  Widget build(BuildContext context) => DetailPage(
    title: 'Microsoft Teams',
    sample: true,
    footer: [
      if (_phase == _Phase.intro)
        FilledButton(
          onPressed: _start,
          child: const Text('Continue with Microsoft'),
        ),
      if (_phase == _Phase.done)
        FilledButton(
          onPressed: () => context.go('/integrations'),
          child: const Text('Done'),
        )
      else
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Not now'),
        ),
    ],
    children: switch (_phase) {
      _Phase.intro => _intro(context),
      _Phase.waiting => const [
        SizedBox(height: 80),
        WaitingRow('Waiting for Microsoft…'),
      ],
      _Phase.done => const [
        SuccessCard(
          title: 'Connected · sample.user@contoso.example',
          body: 'Found 6 meetings this week (sample).',
        ),
        SizedBox(height: 12),
        Text(
          'Meetings sync every few hours when Android allows it.',
          style: AppText.caption,
        ),
      ],
    },
  );

  List<Widget> _intro(BuildContext context) {
    final body = Theme.of(context).textTheme.bodyMedium
        ?.copyWith(color: AppColors.textSecondary);
    return [
      Text(
        'Adds your meetings to the timeline: title, time, duration and '
        'whether it was a Teams call.',
        style: body,
      ),
      const SizedBox(height: 16),
      const AppCard(
        color: AppColors.surface,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionTitle('Microsoft will ask you to allow'),
            ScopeRow(
              scope: 'Calendars.Read',
              reason: 'Read your calendar events',
            ),
            ScopeRow(
              scope: 'User.Read',
              reason: 'Know which account is connected',
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Text(
        'NOT COLLECTED',
        style: AppText.overline.copyWith(color: AppColors.amber),
      ),
      const SizedBox(height: 6),
      Text(
        'Chat messages, meeting recordings, transcripts and attendee emails.',
        style: body,
      ),
      const SizedBox(height: 16),
      const Text(
        'This is separate from signing in with Microsoft. Work accounts may '
        'need IT approval.',
        style: AppText.caption,
      ),
    ];
  }
}
