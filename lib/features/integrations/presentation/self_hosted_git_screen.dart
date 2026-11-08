import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/detail_widgets.dart';

enum _Provider { gitlab, gitlabSelfManaged, githubEnterprise }

const _providers = [
  (
    _Provider.gitlab,
    'GitLab.com',
    'Sign in with a one-time code',
    'gitlab.com',
  ),
  (
    _Provider.gitlabSelfManaged,
    'GitLab self-managed',
    'Your company’s GitLab server',
    'gitlab.example.com',
  ),
  (
    _Provider.githubEnterprise,
    'GitHub Enterprise Server',
    'Your company’s GitHub server',
    'github.example.com',
  ),
];

class SelfHostedGitScreen extends StatefulWidget {
  const SelfHostedGitScreen({super.key});

  @override
  State<SelfHostedGitScreen> createState() => _SelfHostedGitScreenState();
}

class _SelfHostedGitScreenState extends State<SelfHostedGitScreen> {
  var _provider = _Provider.gitlabSelfManaged;
  final _host = TextEditingController(text: _providers[1].$4);

  @override
  void dispose() {
    _host.dispose();
    super.dispose();
  }

  void _select((_Provider, String, String, String) option) => setState(() {
    _provider = option.$1;
    _host.text = option.$4;
  });

  @override
  Widget build(BuildContext context) {
    final label = AppText.caption.copyWith(fontSize: 13);
    return DetailPage(
      title: 'Add Git instance',
      footer: [
        FilledButton(
          onPressed: () => context.push('/integrations/github/connect'),
          child: const Text('Continue'),
        ),
        TextButton(
          onPressed: () => showToast(context, notAvailableYet),
          child: const Text('Use a personal access token instead'),
        ),
      ],
      children: [
        for (final option in _providers)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Semantics(
              selected: option.$1 == _provider,
              button: true,
              child: Material(
                color: option.$1 == _provider
                    ? AppColors.accentTint.withValues(alpha: 0.4)
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: option.$1 == _provider
                        ? AppColors.accent
                        : AppColors.borderStrong,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _select(option),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 60),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          option.$2,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(option.$3, style: AppText.caption),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        Text('Instance address', style: label),
        const SizedBox(height: 8),
        TextField(controller: _host, keyboardType: TextInputType.url),
        const SizedBox(height: 16),
        Text('OAuth application ID (from your admin)', style: label),
        const SizedBox(height: 8),
        const TextField(
          decoration: InputDecoration(hintText: 'Application / client ID'),
        ),
        const SizedBox(height: 12),
        Text(
          _provider == _Provider.gitlab
              ? 'No setup needed for GitLab.com.'
              : 'Each company server needs a WorkPulse OAuth app registered '
                    'once by an admin. WorkPulse only connects to the address '
                    'you enter.',
          style: AppText.caption,
        ),
      ],
    );
  }
}
