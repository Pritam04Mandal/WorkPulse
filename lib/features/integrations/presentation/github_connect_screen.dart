import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../../github/domain/github_models.dart';
import '../../github/presentation/github_controller.dart';
import 'github_repository_list.dart';

class GitHubConnectScreen extends ConsumerStatefulWidget {
  const GitHubConnectScreen({super.key});

  @override
  ConsumerState<GitHubConnectScreen> createState() =>
      _GitHubConnectScreenState();
}

class _GitHubConnectScreenState extends ConsumerState<GitHubConnectScreen> {
  DeviceCode? _code;
  DateTime? _expiresAt;
  GitHubFailureKind? _failure;
  Timer? _ticker;
  int _attempt = 0;
  bool _connected = false;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _attempt = -1;
    super.dispose();
  }

  Future<void> _start() async {
    final attempt = ++_attempt;
    setState(() {
      _code = null;
      _failure = null;
    });
    try {
      final code = await ref.read(githubClientProvider).requestDeviceCode();
      if (attempt != _attempt) return;
      setState(() {
        _code = code;
        _expiresAt = DateTime.now().add(code.expiresIn);
      });
      _ticker?.cancel();
      _ticker = Timer.periodic(
        const Duration(seconds: 1),
        (_) => setState(() {}),
      );
      await _poll(code, attempt);
    } on GitHubFailure catch (failure) {
      if (attempt == _attempt) _fail(failure.kind);
    }
  }

  void _fail(GitHubFailureKind kind) {
    _ticker?.cancel();
    setState(() => _failure = kind);
  }

  Future<void> _poll(DeviceCode code, int attempt) async {
    final client = ref.read(githubClientProvider);
    var interval = code.interval;
    while (attempt == _attempt) {
      await Future<void>.delayed(interval);
      if (attempt != _attempt) return;
      final PollResult result;
      try {
        result = await client.pollForToken(code.deviceCode);
      } on GitHubFailure catch (failure) {
        // A dropped connection isn't fatal while the code is still valid.
        if (failure.kind == GitHubFailureKind.unavailable) continue;
        rethrow;
      }
      if (attempt != _attempt) return;
      switch (result) {
        case PollPending():
          break;
        case PollSlowDown():
          interval += const Duration(seconds: 5);
        case PollToken(:final token, :final scopes):
          await ref
              .read(githubRepositoryProvider)
              .completeConnection(token, scopes);
          _ticker?.cancel();
          if (mounted) setState(() => _connected = true);
          return;
      }
    }
  }

  Future<void> _openGitHub(DeviceCode code) async {
    await copyToClipboard(context, code.userCode, 'Code copied');
    await launchUrl(
      Uri.parse(code.verificationUri),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _startSync() async {
    setState(() => _syncing = true);
    try {
      await ref.read(githubSyncProvider.notifier).refresh(force: true);
    } on GitHubFailure {
      if (mounted) {
        showToast(context, 'Connected, but the first sync didn’t finish.');
      }
    }
    if (mounted) context.pushReplacement('/integrations/github');
  }

  String _remaining() {
    final left = _expiresAt?.difference(DateTime.now()) ?? Duration.zero;
    if (left.isNegative) return '0:00';
    return '${left.inMinutes}:'
        '${left.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  (String, String) _failureCopy(GitHubFailureKind kind) => switch (kind) {
    GitHubFailureKind.notConfigured => (
      'GitHub isn’t configured',
      'This build has no GitHub client ID, or Device Flow is off for the '
          'OAuth App.',
    ),
    GitHubFailureKind.expired => (
      'That code expired',
      'Codes last 15 minutes. Try again for a new one.',
    ),
    GitHubFailureKind.denied => (
      'Access was denied',
      'You cancelled on GitHub. Nothing was connected.',
    ),
    _ => ('Couldn’t reach GitHub', 'Check your connection and try again.'),
  };

  @override
  Widget build(BuildContext context) {
    final code = _code;
    final failure = _failure;
    return DetailPage(
      title: 'Connect GitHub',
      footer: [
        if (_connected)
          FilledButton(
            onPressed: _syncing ? null : _startSync,
            child: Text(_syncing ? 'Syncing…' : 'Start sync'),
          )
        else if (failure != null && failure != GitHubFailureKind.notConfigured)
          FilledButton(onPressed: _start, child: const Text('Try again'))
        else if (code != null)
          FilledButton(
            onPressed: () => _openGitHub(code),
            child: const Text('Copy code and open GitHub'),
          ),
        if (!_connected)
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
      ],
      children: _connected
          ? _done()
          : failure != null
          ? _failed(failure)
          : code == null
          ? const [SizedBox(height: 40), WaitingRow('Contacting GitHub…')]
          : _waiting(code),
    );
  }

  List<Widget> _failed(GitHubFailureKind kind) {
    final (title, body) = _failureCopy(kind);
    return [
      const SizedBox(height: 32),
      const Icon(Icons.error_outline, size: 40, color: AppColors.amber),
      const SizedBox(height: 16),
      Text(title, style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 12),
      Text(
        body,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: AppColors.textSecondary),
      ),
    ];
  }

  List<Widget> _waiting(DeviceCode code) => [
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
          Text(
            'One-time code · expires in ${_remaining()}',
            style: AppText.caption,
          ),
          SelectableText(
            code.userCode,
            style: AppText.mono(size: 32, weight: FontWeight.w600),
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

  List<Widget> _done() {
    final login = ref.watch(githubStatusProvider).value?.login ?? '';
    return [
      SuccessCard(
        title: 'Connected as @$login',
        body: 'First sync: last 30 days of commits, PRs, issues and reviews.',
      ),
      const SizedBox(height: 20),
      const SectionTitle('Repositories'),
      const Text(
        'Ignore any you don’t want tracked before the first sync.',
        style: AppText.caption,
      ),
      const SizedBox(height: 4),
      const GitHubRepositoryList(confirmIgnore: false),
    ];
  }
}
