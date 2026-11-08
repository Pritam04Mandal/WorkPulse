import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/detail_widgets.dart';

const _exampleCode = 'ABCD-1234';

const _repositories = [
  ('sample/workpulse-app', 'New project'),
  ('sample/billing-api', 'New project'),
  ('sample/dotfiles', 'Ignore'),
];

class GitHubConnectScreen extends StatefulWidget {
  const GitHubConnectScreen({super.key});

  @override
  State<GitHubConnectScreen> createState() => _GitHubConnectScreenState();
}

class _GitHubConnectScreenState extends State<GitHubConnectScreen> {
  var _approved = false;

  @override
  Widget build(BuildContext context) => DetailPage(
    title: 'Connect GitHub',
    sample: true,
    footer: [
      if (_approved)
        FilledButton(
          onPressed: () => context.go('/integrations'),
          child: const Text('Start sync'),
        )
      else
        FilledButton(
          onPressed: () => setState(() => _approved = true),
          child: const Text('Open GitHub'),
        ),
      TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
    ],
    children: _approved ? _done(context) : _waiting(context),
  );

  List<Widget> _waiting(BuildContext context) => [
    Text(
      'Enter this code on GitHub to let WorkPulse read your activity. No '
      'password is entered in this app.',
      style: Theme.of(context).textTheme.bodyMedium
          ?.copyWith(color: AppColors.textSecondary),
    ),
    const SizedBox(height: 16),
    AppCard(
      color: AppColors.surface,
      padding: const EdgeInsets.all(20),
      child: Column(
        spacing: 8,
        children: [
          const Text(
            'One-time code · expires in 14:32',
            style: AppText.caption,
          ),
          Text(
            _exampleCode,
            style: AppText.mono(size: 32, weight: FontWeight.w600),
          ),
          const Text(
            'Example code shown in this draft',
            style: AppText.caption,
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size(140, 44)),
            onPressed: () =>
                copyToClipboard(context, _exampleCode, 'Code copied'),
            child: const Text('Copy code'),
          ),
        ],
      ),
    ),
    const SizedBox(height: 16),
    const WaitingRow('Waiting for approval on github.com/login/device'),
    const SizedBox(height: 20),
    const SectionTitle('Access requested'),
    const ScopeRow(
      scope: 'read:user',
      reason: 'Your profile and public activity',
    ),
    const ScopeRow(
      scope: 'repo',
      reason:
          'Needed to see private repositories. WorkPulse only reads; it never '
          'pushes or comments.',
    ),
  ];

  List<Widget> _done(BuildContext context) => [
    const SuccessCard(
      title: 'Connected as @sample-dev',
      body: 'First sync: last 30 days of commits, PRs, issues and reviews.',
    ),
    const SizedBox(height: 20),
    const SectionTitle('Repositories → projects'),
    for (final (repository, action) in _repositories)
      Container(
        constraints: const BoxConstraints(minHeight: 48),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Expanded(child: Text(repository, style: AppText.mono(size: 13))),
            Text(action, style: AppText.caption),
          ],
        ),
      ),
  ];
}
