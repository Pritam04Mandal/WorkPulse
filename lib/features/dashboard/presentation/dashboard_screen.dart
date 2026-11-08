import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/domain/enums.dart';
import '../../../core/format/durations.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/presentation/session_controller.dart';
import '../../github/presentation/github_controller.dart';
import '../../tracking/domain/usage_models.dart';
import '../../tracking/presentation/tracking_controller.dart';
import '../domain/dashboard_summary.dart';

final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  final granted = ref.watch(
    trackingControllerProvider.select((s) => s.usageGranted),
  );
  // Each sync re-evaluates "today", so the screen rolls over at midnight.
  ref.watch(trackingControllerProvider.select((s) => s.lastSyncedAt));
  final today = startOfDay(DateTime.now());
  final activities = ref.watch(dayActivitiesProvider(today)).value ?? const [];
  final github = ref.watch(githubStatusProvider).value;
  return buildDashboardSummary(
    activities,
    usageGranted: granted,
    githubConnected: github?.connected ?? false,
  );
});

Color _categoryColor(ActivityCategory category) => switch (category) {
  ActivityCategory.coding => AppColors.coding,
  ActivityCategory.ai => AppColors.ai,
  ActivityCategory.meetings => AppColors.meetings,
  ActivityCategory.other => AppColors.other,
};

Color _recentColor(RecentKind kind) => switch (kind) {
  RecentKind.coding => AppColors.coding,
  RecentKind.ai => AppColors.ai,
  RecentKind.meeting => AppColors.meetings,
  RecentKind.github => AppColors.accent,
  RecentKind.other => AppColors.muted,
};

String _route(DashboardDestination destination) => switch (destination) {
  DashboardDestination.timeline => '/timeline',
  DashboardDestination.projects => '/projects',
  DashboardDestination.insights => '/insights',
  DashboardDestination.github => '/integrations/github',
  DashboardDestination.integrations => '/integrations',
  DashboardDestination.journal => '/home/journal',
};

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final tracking = ref.watch(trackingControllerProvider);
    final user = ref.watch(sessionProvider.select((s) => s.user));
    final initial = (user?.name ?? 'Local').characters.first.toUpperCase();
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, d MMMM').format(DateTime.now()),
                        style: text.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                      Text('Today', style: text.titleLarge),
                    ],
                  ),
                ),
                Semantics(
                  label: 'Profile',
                  button: true,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => context.push('/settings/profile'),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.border,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (!tracking.usageGranted) ...[
              _Notice(
                title: 'Usage Access is off',
                body: 'WorkPulse can’t see app usage until you allow it.',
                onTap: () => context.push('/usage-access'),
              ),
              const SizedBox(height: 12),
            ],
            if (tracking.privateSession) ...[
              _Notice(
                title: 'Private session is on',
                body: 'Nothing is recorded until you turn it off.',
                onTap: () => context.go('/settings'),
              ),
              const SizedBox(height: 12),
            ],
            _ActiveTrackingCard(summary: summary),
            const SizedBox(height: 20),
            if (summary.latest != null) ...[
              AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                onTap: () =>
                    context.push('/activity/${summary.latest!.entryId}'),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Latest', style: AppText.caption),
                          Text(summary.latest!.title, style: text.titleMedium),
                        ],
                      ),
                    ),
                    Text(
                      formatDuration(summary.latest!.duration),
                      style: AppText.mono(
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            for (var i = 0; i < summary.tiles.length; i += 2) ...[
              if (i > 0) const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 12,
                  children: [
                    Expanded(child: _Tile(tile: summary.tiles[i])),
                    Expanded(child: _Tile(tile: summary.tiles[i + 1])),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text('Recent activity', style: text.titleMedium),
                ),
                InkWell(
                  onTap: () => context.go('/timeline'),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      'Timeline',
                      style: text.bodySmall?.copyWith(color: AppColors.accent),
                    ),
                  ),
                ),
              ],
            ),
            if (summary.recent.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Nothing recorded yet.', style: AppText.caption),
              ),
            for (final item in summary.recent) _RecentRow(item: item),
            const SizedBox(height: 20),
            AppCard(
              padding: const EdgeInsets.all(16),
              onTap: () => context.push(_route(DashboardDestination.journal)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('Daily summary', style: text.titleMedium),
                      ),
                      const Text('Rule-based · draft', style: AppText.caption),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    summary.dailySummary,
                    style: text.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Open journal',
                    style: text.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              onTap: () =>
                  context.push(_route(DashboardDestination.integrations)),
              child: Row(
                children: [
                  const Icon(Icons.link, size: 20, color: AppColors.muted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Integrations',
                          style: text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(summary.integrationsLabel, style: AppText.caption),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.muted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.title, required this.body, required this.onTap});

  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.amberTint,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.amberBorder),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(body, style: AppText.caption),
          ],
        ),
      ),
    ),
  );
}

class _ActiveTrackingCard extends StatelessWidget {
  const _ActiveTrackingCard({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) => AppCard(
    color: AppColors.surface,
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ACTIVE TRACKING', style: AppText.overline),
        const SizedBox(height: 4),
        Text(
          formatDuration(summary.activeTime),
          style: AppText.mono(
            size: 40,
            weight: FontWeight.w600,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Observed app and session time · not verified work time',
          style: AppText.caption,
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 2,
              children: [
                for (final c in summary.categories.where(
                  (c) => c.duration.inMinutes > 0,
                ))
                  Expanded(
                    flex: c.duration.inMinutes,
                    child: ColoredBox(color: _categoryColor(c.category)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            for (final c in summary.categories)
              FractionallySizedBox(
                widthFactor: 0.46,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _categoryColor(c.category),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        c.label,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    Text(
                      formatDuration(c.duration),
                      style: AppText.mono(size: 13),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

class _Tile extends StatelessWidget {
  const _Tile({required this.tile});

  final StatTile tile;

  void _open(BuildContext context) {
    final route = _route(tile.destination);
    if (tile.destination == DashboardDestination.github) {
      context.push(route);
    } else {
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: () => _open(context),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text(tile.label, style: AppText.caption),
        Text(
          tile.value,
          style: AppText.mono(size: 24, weight: FontWeight.w600),
        ),
        Text(tile.caption, style: AppText.caption),
      ],
    ),
  );
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.item});

  final RecentActivity item;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => context.push('/activity/${item.entryId}'),
    child: Container(
      constraints: const BoxConstraints(minHeight: 56),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                item.time,
                style: AppText.mono(color: AppColors.muted),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 3,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _recentColor(item.kind),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(item.subtitle, style: AppText.caption),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatDuration(item.duration),
              style: AppText.mono(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    ),
  );
}
