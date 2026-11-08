import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/detail_widgets.dart';

enum _SyncPhase { idle, syncing, done }

class SourceDetailScreen extends StatefulWidget {
  const SourceDetailScreen({super.key});

  @override
  State<SourceDetailScreen> createState() => _SourceDetailScreenState();
}

class _SourceDetailScreenState extends State<SourceDetailScreen> {
  var _phase = _SyncPhase.idle;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _sync() {
    setState(() => _phase = _SyncPhase.syncing);
    _timer = Timer(
      const Duration(milliseconds: 1500),
      () => setState(() => _phase = _SyncPhase.done),
    );
  }

  void _askDisconnect() => showAppSheet<void>(
    context,
    (sheet) => SheetBody(
      title: 'Disconnect GitHub?',
      body:
          'The saved token is removed from this phone. What should happen to '
          'the 412 GitHub events?',
      actions: [
        OutlinedButton(
          onPressed: () => _finishDisconnect(sheet),
          child: const Text('Keep events, disconnect'),
        ),
        DestructiveButton(
          label: 'Delete events and disconnect',
          onPressed: () => _finishDisconnect(sheet),
        ),
        TextButton(
          onPressed: () => Navigator.pop(sheet),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );

  void _finishDisconnect(BuildContext sheet) {
    Navigator.pop(sheet);
    context.go('/integrations');
  }

  @override
  Widget build(BuildContext context) {
    final syncing = _phase == _SyncPhase.syncing;
    return DetailPage(
      title: 'GitHub',
      sample: true,
      footer: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.destructiveText,
          ),
          onPressed: _askDisconnect,
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
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    'Connected as @sample-dev',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              Text(switch (_phase) {
                _SyncPhase.idle => 'Last synced 4 minutes ago · incremental',
                _SyncPhase.syncing => 'Fetching changes since 13:38…',
                _SyncPhase.done => 'Synced just now · 3 new events',
              }, style: AppText.caption),
              OutlinedButton(
                onPressed: syncing ? null : _sync,
                child: Text(syncing ? 'Syncing…' : 'Sync now'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const KeyValueList(
          rows: [
            ('Events stored', '412', true),
            ('Repositories', '6 tracked · 1 ignored', false),
            ('API budget', '4,870 of 5,000 left this hour', false),
            ('Access', 'read:user, repo', true),
          ],
        ),
        const SizedBox(height: 12),
        NavRow(
          title: 'Repository → project mapping',
          onTap: () => context.push('/projects/workpulse-app'),
        ),
        NavRow(
          title: 'Reconnect account',
          onTap: () => context.push('/integrations/github/connect'),
        ),
      ],
    );
  }
}
