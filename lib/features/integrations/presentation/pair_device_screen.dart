import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/detail_widgets.dart';

class PairDeviceScreen extends StatefulWidget {
  const PairDeviceScreen({this.desktop = false, super.key});

  final bool desktop;

  @override
  State<PairDeviceScreen> createState() => _PairDeviceScreenState();
}

class _PairDeviceScreenState extends State<PairDeviceScreen> {
  late var _desktop = widget.desktop;
  var _paired = false;

  @override
  Widget build(BuildContext context) {
    final device = _desktop ? 'desktop app' : 'extension';
    final steps = _desktop
        ? const [
            'Install the WorkPulse desktop companion',
            'Choose Pair with phone in its menu',
            'Enter the code below',
          ]
        : const [
            'Install WorkPulse for Chrome or Firefox',
            'Open the extension and choose Pair with phone',
            'Enter the code below',
          ];
    final body = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: AppColors.textSecondary);

    return DetailPage(
      title: 'Pair a device',
      sample: true,
      footer: [
        if (_paired)
          FilledButton(
            onPressed: () => context.go('/integrations'),
            child: const Text('Done'),
          )
        else
          FilledButton(
            onPressed: () => setState(() => _paired = true),
            child: Text('Code entered on the $device'),
          ),
      ],
      children: [
        SegmentedTabs(
          options: const [(false, 'Browser extension'), (true, 'Desktop app')],
          value: _desktop,
          onChanged: (desktop) => setState(() {
            _desktop = desktop;
            _paired = false;
          }),
        ),
        const SizedBox(height: 16),
        if (_paired)
          SuccessCard(
            title: _desktop
                ? 'Paired with desktop companion on Linux'
                : 'Paired with Chrome on Linux',
            body: 'Events arrive signed with this device’s key.',
          )
        else ...[
          for (final (index, step) in steps.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('${index + 1}.  $step', style: body),
            ),
          const SizedBox(height: 8),
          AppCard(
            color: AppColors.surface,
            padding: const EdgeInsets.all(20),
            child: Column(
              spacing: 8,
              children: [
                const Text(
                  'Pairing code · same Wi-Fi network',
                  style: AppText.caption,
                ),
                Text(
                  '482 913',
                  style: AppText.mono(size: 32, weight: FontWeight.w600),
                ),
                const Text(
                  'Example code · expires in 4:51',
                  style: AppText.caption,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          WaitingRow('Waiting for the $device…'),
        ],
        const SizedBox(height: 20),
        const SectionTitle('It sends'),
        Text(
          _desktop
              ? 'Active app, coding sessions per folder, git repository and '
                    'branch, and window titles if you allow them.'
              : 'Domain, active time, tab session start and end, and ChatGPT '
                    'or Claude session length. Page titles only if you turn '
                    'them on.',
          style: body,
        ),
        const SizedBox(height: 16),
        const SectionTitle('Never'),
        Text(
          _desktop
              ? 'Keystrokes, screenshots, file contents or clipboard.'
              : 'Page content, form fields, passwords, or anything on '
                    'excluded sites.',
          style: body,
        ),
      ],
    );
  }
}
