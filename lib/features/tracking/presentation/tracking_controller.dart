import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/session_controller.dart';
import '../../github/domain/github_models.dart';
import '../../github/presentation/github_controller.dart';
import '../data/tracking_repository.dart';
import '../data/usage_gateway.dart';
import '../domain/usage_models.dart';

final trackingRepositoryProvider = Provider<TrackingRepository>(
  (ref) => TrackingRepository(
    database: ref.watch(databaseProvider),
    gateway: ref.watch(usageAccessGatewayProvider),
  ),
);

final dayActivitiesProvider = StreamProvider.autoDispose
    .family<List<TrackedActivity>, DateTime>(
      (ref, day) => ref.watch(trackingRepositoryProvider).watchDay(day),
    );

/// Everything from `start` (inclusive) to `end` (exclusive).
final rangeActivitiesProvider = StreamProvider.autoDispose
    .family<List<TrackedActivity>, (DateTime, DateTime)>(
      (ref, range) =>
          ref.watch(trackingRepositoryProvider).watchRange(range.$1, range.$2),
    );

final activityProvider = StreamProvider.autoDispose
    .family<TrackedActivity?, String>(
      (ref, id) => ref.watch(trackingRepositoryProvider).watchActivity(id),
    );

final excludedAppsProvider = StreamProvider.autoDispose<Set<String>>(
  (ref) => ref.watch(trackingRepositoryProvider).watchExcludedApps(),
);

final installedAppsProvider = FutureProvider.autoDispose<List<InstalledApp>>(
  (ref) => ref.watch(trackingRepositoryProvider).installedApps(),
);

class TrackingState {
  const TrackingState({
    this.usageGranted = true,
    this.privateSession = false,
    this.lastSyncedAt,
  });

  final bool usageGranted;
  final bool privateSession;
  final DateTime? lastSyncedAt;
}

final trackingControllerProvider =
    NotifierProvider<TrackingController, TrackingState>(TrackingController.new);

class TrackingController extends Notifier<TrackingState> {
  var _syncing = false;

  TrackingRepository get _repository => ref.read(trackingRepositoryProvider);

  @override
  TrackingState build() {
    ref.listen(sessionProvider.select((s) => s.onboardingComplete), (_, done) {
      if (done) refresh();
    });
    return const TrackingState();
  }

  /// Catches up from Android's log. Safe to call at any time.
  Future<void> refresh() async {
    if (_syncing || !ref.read(sessionProvider).onboardingComplete) return;
    _syncing = true;
    try {
      final granted = await _repository.sync();
      final private = await _repository.isPrivateSession();
      if (!ref.mounted) return;
      state = TrackingState(
        usageGranted: granted,
        privateSession: private,
        lastSyncedAt: DateTime.now(),
      );
    } on PlatformException {
      // The log is still there; the next launch or resume retries.
    } finally {
      _syncing = false;
    }
  }

  Future<void> setPrivateSession(bool on) async {
    // GitHub keeps its history, so bring it up to date before the pause.
    if (on) {
      try {
        await ref.read(githubSyncProvider.notifier).refresh(force: true);
      } on GitHubFailure {
        // Privacy must never depend on the network.
      }
    }
    await _repository.setPrivateSession(on);
    if (!ref.mounted) return;
    state = TrackingState(
      usageGranted: state.usageGranted,
      privateSession: on,
      lastSyncedAt: state.lastSyncedAt,
    );
  }
}
