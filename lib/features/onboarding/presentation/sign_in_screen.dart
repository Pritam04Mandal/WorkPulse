import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/domain/enums.dart';
import '../../../core/theme/tokens.dart';
import '../../auth/domain/auth_models.dart';
import '../../auth/presentation/session_controller.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({required this.provider, super.key});

  final AuthProvider provider;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  UserProfile? _user;
  AuthFailureKind? _failure;

  bool get _loading => _user == null && _failure == null;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    if (_failure != null) setState(() => _failure = null);
    try {
      final user = await ref
          .read(sessionProvider.notifier)
          .signIn(widget.provider);
      if (mounted) setState(() => _user = user);
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _failure = e.kind);
    } on Exception {
      // Plugin or storage errors: details could hold credentials, so they
      // are deliberately neither shown nor logged.
      if (mounted) setState(() => _failure = AuthFailureKind.unavailable);
    }
  }

  Future<void> _continueLocally() async {
    await ref.read(sessionProvider.notifier).continueWithoutAccount();
    if (mounted) _next();
  }

  /// Onboarding moves on to Usage Access; Profile just returns.
  void _next() {
    if (ref.read(sessionProvider).onboardingComplete) {
      context.pop();
    } else {
      context.pushReplacement('/usage-access');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: BackButton(onPressed: () => context.pop()),
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: switch ((_user, _failure)) {
                  (final UserProfile user, _) => _Success(user: user),
                  (_, final AuthFailureKind kind) => _Failure(
                    kind: kind,
                    provider: widget.provider,
                  ),
                  _ => const _Loading(),
                },
              ),
            ),
            ..._actions(),
          ],
        ),
      ),
    ),
  );

  List<Widget> _actions() {
    if (_loading) {
      return [
        OutlinedButton(
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
      ];
    }
    if (_user != null) {
      return [FilledButton(onPressed: _next, child: const Text('Continue'))];
    }
    return [
      if (_failure != AuthFailureKind.notConfigured) ...[
        FilledButton(onPressed: _start, child: const Text('Try again')),
        const SizedBox(height: 10),
      ],
      OutlinedButton(
        onPressed: _continueLocally,
        child: const Text('Continue without account'),
      ),
    ];
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 120),
    child: Column(
      children: [
        const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.accent,
            backgroundColor: AppColors.border,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Signing you in',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        Text(
          'Finish in the account window. WorkPulse only asks for your name, '
          'email and profile picture.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.muted),
        ),
      ],
    ),
  );
}

class _Success extends StatelessWidget {
  const _Success({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final name = user.name ?? user.email ?? 'there';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.border,
            shape: BoxShape.circle,
          ),
          child: Text(
            name.characters.first.toUpperCase(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 20),
        Text('Welcome, $name', style: text.headlineSmall),
        if (user.email != null) ...[
          const SizedBox(height: 6),
          Text(
            user.email!,
            style: text.bodyMedium?.copyWith(color: AppColors.muted),
          ),
        ],
        const SizedBox(height: 20),
        Text(
          'Your profile is saved on this phone. Nothing else from your account '
          'was shared.',
          style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _Failure extends StatelessWidget {
  const _Failure({required this.kind, required this.provider});

  final AuthFailureKind kind;
  final AuthProvider provider;

  @override
  Widget build(BuildContext context) {
    final providerName = provider == AuthProvider.google
        ? 'Google'
        : 'Microsoft';
    final (title, body, color) = switch (kind) {
      AuthFailureKind.cancelled => (
        'Sign-in cancelled',
        'You closed the account window. Nothing was saved.',
        AppColors.muted,
      ),
      AuthFailureKind.unavailable => (
        'Couldn’t reach the provider',
        'Check your connection and try again. You can also use WorkPulse '
            'without an account.',
        AppColors.destructiveText,
      ),
      AuthFailureKind.expired => (
        'Session expired',
        'Your previous sign-in is no longer valid. Sign in again to restore '
            'your profile.',
        AppColors.amber,
      ),
      AuthFailureKind.notConfigured => (
        '$providerName sign-in isn’t configured',
        'This build has no $providerName client ID. You can still use '
            'WorkPulse without an account.',
        AppColors.amber,
      ),
    };
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 40, color: color),
          const SizedBox(height: 16),
          Text(title, style: text.headlineSmall),
          const SizedBox(height: 16),
          Text(
            body,
            style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
