import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../../auth/presentation/session_controller.dart';
import '../../onboarding/data/usage_access_gateway.dart';
import '../data/sample_exclusions.dart';

const privateSessionSettingKey = 'private_session';

final _usageAccessProvider = FutureProvider.autoDispose<bool?>((ref) async {
  try {
    return await ref.watch(usageAccessGatewayProvider).isGranted();
  } on PlatformException {
    return null;
  }
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final AppLifecycleListener _lifecycle;
  var _private = false;

  @override
  void initState() {
    super.initState();
    // Usage Access changes in Android settings, outside the app.
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(_usageAccessProvider),
    );
    _loadPrivate();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _loadPrivate() async {
    final value = await ref
        .read(databaseProvider)
        .readSetting(privateSessionSettingKey);
    if (mounted) setState(() => _private = value == 'true');
  }

  Future<void> _setPrivate(bool value) async {
    setState(() => _private = value);
    await ref
        .read(databaseProvider)
        .writeSetting(privateSessionSettingKey, '$value');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider.select((s) => s.user));
    final excluded = ref.watch(sampleExclusionsProvider);
    final granted = ref.watch(_usageAccessProvider).value;
    final text = Theme.of(context).textTheme;
    final name = user == null || user.isLocal
        ? 'Local profile'
        : user.name ?? user.email ?? 'Signed in';
    final isLocal = user == null || user.isLocal;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const TabHeader(title: 'Settings', trailing: [SampleDataChip()]),
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
              hint: _private
                  ? 'On · nothing is recorded until you turn it off'
                  : 'Pause all collection for a while',
              value: _private,
              onChanged: _setPrivate,
            ),
            NavRow(
              title: 'Integrations',
              value: '5 connected',
              onTap: () => context.push('/integrations'),
            ),
            NavRow(
              title: 'Excluded apps',
              value: '${countExcluded(excluded, sampleExcludableApps)} apps',
              onTap: () => context.push('/settings/exclusions'),
            ),
            NavRow(
              title: 'Excluded websites',
              value: '${countExcluded(excluded, sampleExcludableSites)} sites',
              onTap: () => context.push('/settings/exclusions?tab=sites'),
            ),
            NavRow(
              title: 'Usage Access',
              value: switch (granted) {
                true => 'Granted',
                false => 'Not granted',
                null => null,
              },
              onTap: () => context.push('/usage-access'),
            ),
            const SizedBox(height: 24),
            const SectionTitle('Security'),
            const _SwitchRow(
              title: 'Biometric app lock',
              hint: 'Not available yet',
              value: false,
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
