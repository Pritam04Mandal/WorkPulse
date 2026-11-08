import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../../companion/domain/companion_models.dart';
import '../../companion/presentation/companion_controller.dart';

const _script = 'companion/claude-code/workpulse_claude.py';

class ClaudeCodeScreen extends ConsumerStatefulWidget {
  const ClaudeCodeScreen({super.key});

  @override
  ConsumerState<ClaudeCodeScreen> createState() => _ClaudeCodeScreenState();
}

class _ClaudeCodeScreenState extends ConsumerState<ClaudeCodeScreen> {
  late final Timer _ticker;
  late final CompanionController _controller;
  var _pairingRequested = false;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(companionControllerProvider.notifier);
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker.cancel();
    // Provider state can't change while the widget tree is being torn down.
    Future.microtask(_controller.cancelPairing);
    super.dispose();
  }

  void _startPairing() {
    if (_pairingRequested) return;
    _pairingRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.beginPairing();
    });
  }

  void _askUnpair(PairedDevice device) => showAppSheet<void>(
    context,
    (sheet) => SheetBody(
      title: 'Unpair ${device.name}?',
      body: 'This computer will stop sending sessions to this phone.',
      actions: [
        OutlinedButton(
          onPressed: () => _unpair(sheet, device, keepEvents: true),
          child: const Text('Keep sessions, unpair'),
        ),
        DestructiveButton(
          label: 'Delete sessions and unpair',
          onPressed: () => _unpair(sheet, device, keepEvents: false),
        ),
        TextButton(
          onPressed: () => Navigator.pop(sheet),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );

  Future<void> _unpair(
    BuildContext sheet,
    PairedDevice device, {
    required bool keepEvents,
  }) async {
    Navigator.pop(sheet);
    _pairingRequested = false;
    await ref
        .read(companionRepositoryProvider)
        .unpair(device.id, keepEvents: keepEvents);
  }

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(pairedDevicesProvider).value;
    final state = ref.watch(companionControllerProvider);
    if (devices != null && devices.isEmpty) _startPairing();
    if (devices == null) {
      return const DetailPage(title: 'Claude Code', children: []);
    }

    return DetailPage(
      title: 'Claude Code',
      children: [
        for (final device in devices) ...[
          _DeviceCard(device: device, onUnpair: () => _askUnpair(device)),
          const SizedBox(height: 12),
        ],
        if (devices.isEmpty) ..._pairing(state),
        if (devices.isNotEmpty) ...[
          Text(
            'Sessions arrive while this app is open. Otherwise your computer '
            'holds them and sends them after your next Claude Code prompt '
            'with the app open.',
            style: AppText.caption.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 20),
        ],
        const SectionTitle('It sends'),
        const Text(
          'When you worked, the project folder name and the git repository '
          'name.',
          style: AppText.caption,
        ),
        const SizedBox(height: 16),
        const SectionTitle('Never'),
        const Text(
          'Your prompts, Claude’s responses, file contents or full file '
          'paths.',
          style: AppText.caption,
        ),
      ],
    );
  }

  List<Widget> _pairing(CompanionState state) {
    final offer = state.offer;
    if (offer == null) return const [WaitingRow('Preparing…')];
    final address = offer.address;
    if (address == null) {
      return const [
        Text(
          'Connect this phone to Wi-Fi, the same network as your computer, '
          'then reopen this screen.',
          style: AppText.caption,
        ),
        SizedBox(height: 20),
      ];
    }
    if (state.portBusy) {
      return const [
        Text(
          'Another app is using the port WorkPulse needs. Close it and '
          'reopen this screen.',
          style: AppText.caption,
        ),
        SizedBox(height: 20),
      ];
    }
    final left = offer.expiresAt.difference(DateTime.now());
    if (left.isNegative) {
      return [
        const Text('That code expired.', style: AppText.caption),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _controller.beginPairing,
          child: const Text('Get a new code'),
        ),
        const SizedBox(height: 20),
      ];
    }
    return _pairingSteps(offer, address, left);
  }

  List<Widget> _pairingSteps(
    PairingOffer offer,
    String address,
    Duration left,
  ) {
    final pairCommand = 'python3 $_script pair $address ${offer.code}';
    final installCommand = 'python3 $_script install';
    final seconds = left.inSeconds.remainder(60).toString().padLeft(2, '0');
    return [
      Text(
        'Keep this screen open. In the WorkPulse project folder on your '
        'computer, run these two commands.',
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
              'Pairing code · expires in ${left.inMinutes}:$seconds',
              style: AppText.caption,
            ),
            SelectableText(
              offer.code,
              style: AppText.mono(size: 32, weight: FontWeight.w600),
            ),
            Text(address, style: AppText.mono(color: AppColors.muted)),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _CommandBox(step: '1', command: pairCommand),
      const SizedBox(height: 10),
      _CommandBox(step: '2', command: installCommand),
      const SizedBox(height: 16),
      const WaitingRow('Waiting for your computer…'),
      const SizedBox(height: 20),
    ];
  }
}

class _CommandBox extends StatelessWidget {
  const _CommandBox({required this.step, required this.command});

  final String step;
  final String command;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
    child: Row(
      spacing: 8,
      children: [
        Text(step, style: AppText.mono(color: AppColors.muted)),
        Expanded(child: SelectableText(command, style: AppText.mono())),
        IconButton(
          tooltip: 'Copy command',
          onPressed: () => copyToClipboard(context, command, 'Command copied'),
          icon: const Icon(Icons.copy, size: 18, color: AppColors.muted),
        ),
      ],
    ),
  );
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.device, required this.onUnpair});

  final PairedDevice device;
  final VoidCallback onUnpair;

  @override
  Widget build(BuildContext context) {
    final seen = device.lastSeenAt;
    return AppCard(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          Text(
            'Paired with ${device.name}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            seen == null
                ? 'No sessions received yet'
                : 'Last update ${DateFormat('d MMM, HH:mm').format(seen)}',
            style: AppText.caption,
          ),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onUnpair, child: const Text('Unpair')),
        ],
      ),
    );
  }
}
