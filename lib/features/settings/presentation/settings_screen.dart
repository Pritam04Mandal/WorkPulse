import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../../auth/presentation/session_controller.dart';
import '../../security/presentation/app_lock.dart';
import '../../tracking/presentation/tracking_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider.select((s) => s.user));
    final tracking = ref.watch(trackingControllerProvider);
    final lock = ref.watch(appLockProvider);
    final excludedApps = ref.watch(excludedAppsProvider).value?.length ?? 0;
    final text = Theme.of(context).textTheme;
    final isLocal = user == null || user.isLocal;
    final name = isLocal
        ? 'Local profile'
        : user.name ?? user.email ?? 'Account';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const TabHeader(title: 'Settings'),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.all(14),
              onTap: () => context.push('/settings/profile'),
              child: Row(
                spacing: 12,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.border,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      name.characters.first.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: text.titleMedium),
                        Text(
                          isLocal
                              ? 'No account · data only on this phone'
                              : user.email ?? '',
                          style: AppText.caption,
                        ),
                      ],
                    ),
                  ),
                  if (isLocal)
                    Text(
                      'Sign in',
                      style: text.bodySmall?.copyWith(color: AppColors.accent),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionTitle('Tracking'),
            _SwitchRow(
              title: 'Private session',
              hint: tracking.privateSession
                  ? 'On · nothing is recorded until you turn it off'
                  : 'Pause all collection for a while',
              value: tracking.privateSession,
              onChanged: ref
                  .read(trackingControllerProvider.notifier)
                  .setPrivateSession,
            ),
            NavRow(
              title: 'Integrations',
              onTap: () => context.push('/integrations'),
            ),
            NavRow(
              title: 'Excluded apps',
              value: '$excludedApps apps',
              onTap: () => context.push('/settings/exclusions'),
            ),
            NavRow(
              title: 'Usage Access',
              value: tracking.usageGranted ? 'Granted' : 'Not granted',
              onTap: () => context.push('/usage-access'),
            ),
            const SizedBox(height: 24),
            const SectionTitle('Security'),
            _SwitchRow(
              title: 'Biometric app lock',
              hint: lock.enabled
                  ? 'On · asks when you open WorkPulse'
                  : 'Ask for your fingerprint, face or screen lock',
              value: lock.enabled,
              onChanged: (on) async {
                final result = await ref
                    .read(appLockProvider.notifier)
                    .setEnabled(on);
                if (!context.mounted) return;
                if (result == LockChangeResult.unavailable) {
                  showToast(
                    context,
                    'Set up a screen lock on this phone first.',
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            const SectionTitle('Your data'),
            NavRow(
              title: 'Export all data',
              value: 'JSON · CSV',
              onTap: () => showToast(context, notAvailableYet),
            ),
            NavRow(
              title: 'Delete all local data',
              color: AppColors.destructiveText,
              onTap: () => context.push('/settings/delete-data'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Without a WorkPulse server there is no account recovery or '
              'cross-device sync. Export before switching phones.',
              style: AppText.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.hint,
    required this.value,
    this.onChanged,
  });

  final String title;
  final String hint;
  final bool value;

  /// Null shows the switch as disabled.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 60),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(hint, style: AppText.caption),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    ),
  );
}
