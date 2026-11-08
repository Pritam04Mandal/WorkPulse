import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../../companion/presentation/companion_controller.dart';
import '../../github/presentation/github_controller.dart';
import '../../tracking/presentation/tracking_controller.dart';

const _otherItems = [
  (
    mono: 'BX',
    name: 'Browser extension',
    detail: 'ChatGPT, Claude and website time',
    status: 'Planned',
    color: AppColors.muted,
    route: null,
  ),
  (
    mono: 'GL',
    name: 'GitLab or GitHub Enterprise',
    detail: 'Company or self-hosted instances',
    status: 'Planned',
    color: AppColors.muted,
    route: null,
  ),
  (
    mono: 'AI',
    name: 'Local AI summaries',
    detail: 'Ollama on your network',
    status: 'Planned',
    color: AppColors.muted,
    route: null,
  ),
];

class IntegrationsScreen extends ConsumerWidget {
  const IntegrationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracking = ref.watch(trackingControllerProvider);
    final github = ref.watch(githubStatusProvider).value;
    final githubOn = github?.connected ?? false;
    final synced = github?.lastSyncedAt;
    final claude = ref.watch(pairedDevicesProvider).value ?? const [];
    final items = [
      (
        mono: 'A',
        name: 'Android app usage',
        detail: tracking.usageGranted
            ? 'Usage Access granted'
            : 'Needs Usage Access',
        status: tracking.usageGranted ? 'Active' : 'Off',
        color: tracking.usageGranted ? AppColors.accent : AppColors.amber,
        route: '/usage-access' as String?,
      ),
      (
        mono: 'GH',
        name: 'GitHub',
        detail: !githubOn
            ? 'Commits, pull requests, issues and reviews'
            : synced == null
            ? '@${github!.login}'
            : '@${github!.login} · synced '
                  '${DateFormat('d MMM, HH:mm').format(synced)}',
        status: githubOn ? 'Connected' : 'Add',
        color: githubOn ? AppColors.accent : AppColors.coding,
        route:
            (githubOn ? '/integrations/github' : '/integrations/github/connect')
                as String?,
      ),
      (
        mono: 'CC',
        name: 'Claude Code',
        detail: claude.isEmpty
            ? 'Session times from your computer'
            : claude.map((d) => d.name).join(', '),
        status: claude.isEmpty ? 'Add' : 'Paired',
        color: claude.isEmpty ? AppColors.coding : AppColors.accent,
        route: '/integrations/claude' as String?,
      ),
      (
        mono: 'VS',
        name: 'VS Code',
        detail: claude.isEmpty
            ? 'Coding time from your computer'
            : 'Uses your computer’s pairing',
        status: claude.isEmpty ? 'Add' : 'Ready',
        color: claude.isEmpty ? AppColors.coding : AppColors.accent,
        route: '/integrations/vscode' as String?,
      ),
      ..._otherItems,
    ];
    return DetailPage(
      title: 'Integrations',
      children: [
        Text(
          'Each source is connected and removed on its own. Disconnecting asks '
          'whether to keep or delete its events.',
          style: AppText.caption.copyWith(fontSize: 13),
        ),
        const SizedBox(height: 8),
        for (final item in items)
          InkWell(
            onTap: item.route == null ? null : () => context.push(item.route!),
            child: Container(
              constraints: const BoxConstraints(minHeight: 64),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                spacing: 12,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderStrong),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(item.mono, style: AppText.mono()),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.name,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        Text(item.detail, style: AppText.caption),
                      ],
                    ),
                  ),
                  Row(
                    spacing: 6,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(item.status, style: AppText.caption),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
