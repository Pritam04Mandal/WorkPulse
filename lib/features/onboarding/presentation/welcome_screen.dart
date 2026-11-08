import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/presentation/session_controller.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  Future<void> _continueLocally(BuildContext context, WidgetRef ref) async {
    await ref.read(sessionProvider.notifier).continueWithoutAccount();
    if (context.mounted) context.push('/usage-access');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 72,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.borderStrong),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const PulseMark(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('WorkPulse', style: text.headlineLarge),
                    const SizedBox(height: 10),
                    Text(
                      'Understand your working day without keeping a work log.',
                      style: text.bodyLarge?.copyWith(
                        fontSize: 17,
                        height: 1.45,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const _Promise(
                      icon: Icons.smartphone_outlined,
                      title: 'Stays on this device',
                      body: 'Local SQLite database. No WorkPulse server.',
                    ),
                    const SizedBox(height: 16),
                    const _Promise(
                      icon: Icons.shield_outlined,
                      title: 'Metadata, never content',
                      body:
                          'No keystrokes, screens, notifications or messages.',
                    ),
                    const SizedBox(height: 16),
                    const _Promise(
                      icon: Icons.link,
                      title: 'Every source is opt-in',
                      body: 'Connect GitHub and your editors separately, disconnect any time.',
                    ),
                    const Spacer(),
                    const SizedBox(height: 32),
                    _ProviderButton(
                      label: 'Continue with Google',
                      badge: 'G',
                      badgeRadius: 11,
                      onPressed: () => context.push('/sign-in/google'),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => _continueLocally(context, ref),
                      child: const Text('Continue without account'),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Signing in only identifies you (openid, profile, email).',
                      textAlign: TextAlign.center,
                      style: AppText.caption,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Promise extends StatelessWidget {
  const _Promise({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: AppColors.accent),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(
              body,
              style: AppText.caption.copyWith(fontSize: 13, height: 1.45),
            ),
          ],
        ),
      ),
    ],
  );
}

class _ProviderButton extends StatelessWidget {
  const _ProviderButton({
    required this.label,
    required this.badge,
    required this.badgeRadius,
    required this.onPressed,
  });

  final String label;
  final String badge;
  final double badgeRadius;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    style: OutlinedButton.styleFrom(backgroundColor: AppColors.surface),
    onPressed: onPressed,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.text,
            borderRadius: BorderRadius.circular(badgeRadius),
          ),
          child: Text(
            badge,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.background,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    ),
  );
}
