import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../auth/presentation/session_controller.dart';
import '../data/companion_repository.dart';
import '../data/companion_secrets.dart';
import '../data/companion_server.dart';
import '../domain/companion_models.dart';

final companionRepositoryProvider = Provider<CompanionRepository>(
  (ref) => CompanionRepository(
    database: ref.watch(databaseProvider),
    secrets: ref.watch(companionSecretsProvider),
  ),
);

final pairedDevicesProvider = StreamProvider<List<PairedDevice>>(
  (ref) => ref.watch(companionRepositoryProvider).watchDevices(),
);

class CompanionState {
  const CompanionState({this.offer, this.portBusy = false});

  final PairingOffer? offer;

  /// Another app holds the port, so computers can't reach this phone.
  final bool portBusy;
}

final companionControllerProvider =
    NotifierProvider<CompanionController, CompanionState>(
      CompanionController.new,
    );

/// Runs the local receiver while the app is in the foreground.
class CompanionController extends Notifier<CompanionState> {
  CompanionServer? _server;
  var _foreground = true;

  CompanionServer get _instance => _server ??= CompanionServer(
    ref.read(companionRepositoryProvider),
    onPaired: () {
      if (ref.mounted) state = CompanionState(portBusy: state.portBusy);
    },
  );

  @override
  CompanionState build() {
    ref.onDispose(() => _server?.stop());
    return const CompanionState();
  }

  Future<void> resume() async {
    _foreground = true;
    final needed =
        state.offer != null ||
        await ref.read(companionRepositoryProvider).hasDevices();
    if (needed) await _startServer();
  }

  /// Android would suspend the receiver anyway. Computers hold their events
  /// and send them the next time the app is open.
  Future<void> pause() async {
    _foreground = false;
    await _server?.stop();
  }

  Future<void> beginPairing() async {
    final server = _instance;
    final issued = server.beginPairing();
    final ip = await localNetworkAddress();
    if (!ref.mounted) return;
    state = CompanionState(
      offer: PairingOffer(
        code: issued.code,
        expiresAt: issued.expiresAt,
        address: ip == null ? null : '$ip:$companionPort',
      ),
    );
    if (_foreground) await _startServer();
  }

  void cancelPairing() {
    if (!ref.mounted) return;
    _server?.cancelPairing();
    state = CompanionState(portBusy: state.portBusy);
  }

  Future<void> _startServer() async {
    try {
      await _instance.start();
      if (ref.mounted && state.portBusy) {
        state = CompanionState(offer: state.offer);
      }
    } on SocketException {
      if (ref.mounted) {
        state = CompanionState(offer: state.offer, portBusy: true);
      }
    }
  }
}
