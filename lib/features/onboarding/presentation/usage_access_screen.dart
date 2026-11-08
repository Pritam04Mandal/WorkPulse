import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/tokens.dart';
import '../../auth/presentation/session_controller.dart';
import '../data/usage_access_gateway.dart';

class UsageAccessScreen extends ConsumerStatefulWidget {
  const UsageAccessScreen({super.key});

  @override
  ConsumerState<UsageAccessScreen> createState() => _UsageAccessScreenState();
}

class _UsageAccessScreenState extends ConsumerState<UsageAccessScreen>
    with WidgetsBindingObserver {
  bool _openedSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _openedSettings) {
      _finishIfGranted();
    }
  }

  Future<void> _finishIfGranted() async {
    _openedSettings = false;
    try {
      if (await ref.read(usageAccessGatewayProvider).isGranted()) {
        await _finish();
      }
    } on PlatformException {
      // Stay here; "Not now" is still available.
    }
  }

  Future<void> _openSettings() async {
    try {
      await ref.read(usageAccessGatewayProvider).openSettings();
      _openedSettings = true;
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn’t open Android settings.')),
      );
    }
  }

  /// Onboarding continues to Home; from Settings this just returns.
  Future<void> _finish() async {
    if (ref.read(sessionProvider).onboardingComplete) {
      if (mounted) context.pop();
      return;
    }
    await ref.read(sessionProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: context.canPop() ? const BackButton() : null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Center(
              child: Text('Setup', style: AppText.mono(color: AppColors.muted)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Allow Usage Access', style: text.headlineMedium),
                      const SizedBox(height: 10),
                      Text(
                        'WorkPulse uses Android’s usage statistics to see '
                        'which apps were in the foreground, and for how long.',
                        style: text.bodyLarge?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _ScopeCard(
                                label: 'READS',
                                color: AppColors.accent,
                                lines: 'App package names\nForeground time\nApp switches',
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _ScopeCard(
                                label: 'NEVER READS',
                                color: AppColors.amber,
                                lines: 'Screen content\nKeystrokes\nNotifications, messages',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'In the next screen',
                        style: text.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const _Step(1, 'Find WorkPulse in the list'),
                      const SizedBox(height: 12),
                      const _Step(2, 'Turn on "Permit usage access"'),
                      const SizedBox(height: 12),
                      const _Step(3, 'Press back to return here'),
                      const SizedBox(height: 28),
                      const Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: 16),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: AppColors.muted,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Android limits background work, so WorkPulse '
                              'catches up from the OS usage log when it next '
                              'runs. Short gaps are normal.',
                              style: AppText.caption,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _openSettings,
                child: const Text('Open Usage Access settings'),
              ),
              const SizedBox(height: 10),
              TextButton(onPressed: _finish, child: const Text('Not now')),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScopeCard extends StatelessWidget {
  const _ScopeCard({
    required this.label,
    required this.color,
    required this.lines,
  });

  final String label;
  final Color color;
  final String lines;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.overline.copyWith(color: color)),
        const SizedBox(height: 10),
        Text(
          lines,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    ),
  );
}

class _Step extends StatelessWidget {
  const _Step(this.number, this.label);

  final int number;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: Text('$number', style: AppText.mono()),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ),
    ],
  );
}
