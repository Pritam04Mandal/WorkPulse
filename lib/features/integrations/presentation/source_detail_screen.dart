import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../../github/domain/github_models.dart';
import '../../github/presentation/github_controller.dart';
import 'github_repository_list.dart';

class SourceDetailScreen extends ConsumerWidget {
  const SourceDetailScreen({super.key});

  Future<void> _sync(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(githubSyncProvider.notifier).refresh(force: true);
      ref.invalidate(githubRateBudgetProvider);
    } on GitHubFailure catch (failure) {
      if (!context.mounted) return;
      showToast(
        context,
        failure.kind == GitHubFailureKind.revoked
            ? 'GitHub rejected the saved access. Reconnect your account.'
            : 'Couldn’t reach GitHub. Try again in a moment.',
      );
    }
  }

  void _askDisconnect(
    BuildContext context,
    WidgetRef ref,
    GitHubStatus status,
  ) {
    Future<void> finish(BuildContext sheet, {required bool keepEvents}) async {
      Navigator.pop(sheet);
      await ref
          .read(githubRepositoryProvider)
          .disconnect(keepEvents: keepEvents);
      if (context.mounted) context.pop();
    }

    showAppSheet<void>(
      context,
      (sheet) => SheetBody(
        title: 'Disconnect GitHub?',
        body:
            'The saved token is removed from this phone. What should happen '
            'to the ${status.eventCount} GitHub events?',
        actions: [
          OutlinedButton(
            onPressed: () => finish(sheet, keepEvents: true),
            child: const Text('Keep events, disconnect'),
          ),
          DestructiveButton(
            label: 'Delete events and disconnect',
            onPressed: () => finish(sheet, keepEvents: false),
          ),
          TextButton(
            onPressed: () => Navigator.pop(sheet),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _syncedText(GitHubStatus status) {
    final synced = status.lastSyncedAt;
    return synced == null
        ? 'Not synced yet'
        : 'Last synced ${DateFormat('d MMM, HH:mm').format(synced)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(githubStatusProvider).value;
    if (status == null || !status.connected) {
      return DetailPage(
        title: 'GitHub',
        footer: [
          FilledButton(
            onPressed: () =>
                context.pushReplacement('/integrations/github/connect'),
            child: const Text('Connect GitHub'),
          ),
        ],
        children: [
          Text(
            status == null
                ? 'Not connected.'
                : 'Not connected. ${status.eventCount} events from '
                      '@${status.login} are still on this phone.',
            style: AppText.caption.copyWith(fontSize: 14),
          ),
        ],
      );
    }

    final syncing = ref.watch(githubSyncProvider);
    final budget = ref.watch(githubRateBudgetProvider).value;
    final number = NumberFormat.decimalPattern();

    return DetailPage(
      title: 'GitHub',
      footer: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.destructiveText,
          ),
          onPressed: () => _askDisconnect(context, ref, status),
          child: const Text('Disconnect GitHub'),
        ),
      ],
      children: [
        AppCard(
          color: AppColors.surface,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Row(
                spacing: 8,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: status.needsReconnect
                          ? AppColors.amber
                          : AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      status.needsReconnect
                          ? 'Access for @${status.login} was revoked'
                          : 'Connected as @${status.login}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              Text(
                syncing ? 'Fetching changes…' : _syncedText(status),
                style: AppText.caption,
              ),
              OutlinedButton(
                onPressed: syncing ? null : () => _sync(context, ref),
                child: Text(syncing ? 'Syncing…' : 'Sync now'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        KeyValueList(
          rows: [
            ('Events stored', number.format(status.eventCount), true),
            (
              'Repositories',
              '${status.trackedRepositories} tracked · '
                  '${status.ignoredRepositories} ignored',
              false,
            ),
            if (budget != null)
              (
                'API budget',
                '${number.format(budget.remaining)} of '
                    '${number.format(budget.limit)} left this hour',
                false,
              ),
            if (status.scopes != null) ('Access', status.scopes!, true),
          ],
        ),
        const SizedBox(height: 12),
        NavRow(
          title: 'Reconnect account',
          color: status.needsReconnect ? AppColors.amber : null,
          onTap: () => context.push('/integrations/github/connect'),
        ),
        const SizedBox(height: 12),
        const SectionTitle('Repositories'),
        const GitHubRepositoryList(),
      ],
    );
  }
}
