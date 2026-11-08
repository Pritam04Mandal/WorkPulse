import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/auth_config.dart';
import '../../../core/database/app_database.dart';
import '../../auth/presentation/session_controller.dart';
import '../data/github_api.dart';
import '../data/github_repository.dart';
import '../data/github_token_store.dart';
import '../domain/github_models.dart';

const _autoSyncEvery = Duration(minutes: 15);

final githubClientProvider = Provider<GitHubClient>((ref) {
  final http_ = http.Client();
  ref.onDispose(http_.close);
  return GitHubApi(http_, const AuthConfig().githubClientId);
});

final githubRepositoryProvider = Provider<GitHubRepository>(
  (ref) => GitHubRepository(
    database: ref.watch(databaseProvider),
    client: ref.watch(githubClientProvider),
    tokens: ref.watch(githubTokenStoreProvider),
  ),
);

final githubStatusProvider = StreamProvider<GitHubStatus?>(
  (ref) => ref.watch(githubRepositoryProvider).watchStatus(),
);

final githubRepositoriesProvider =
    StreamProvider.autoDispose<List<TrackedRepository>>(
      (ref) => ref.watch(githubRepositoryProvider).watchRepositories(),
    );

final githubRateBudgetProvider = FutureProvider.autoDispose<RateBudget?>(
  (ref) => ref.watch(githubRepositoryProvider).rateBudget(),
);

final githubSyncProvider = NotifierProvider<GitHubSync, bool>(GitHubSync.new);

/// State is whether a sync is running.
class GitHubSync extends Notifier<bool> {
  @override
  bool build() => false;

  /// Syncs if connected. Without [force], at most every 15 minutes and
  /// quietly: a failure just waits for the next attempt.
  Future<void> refresh({bool force = false}) async {
    if (state || !ref.read(sessionProvider).onboardingComplete) return;
    final repository = ref.read(githubRepositoryProvider);
    if (!force) {
      final last = await repository.lastSyncedAt();
      if (last != null && DateTime.now().difference(last) < _autoSyncEvery) {
        return;
      }
    }
    state = true;
    try {
      await repository.sync();
    } on GitHubFailure {
      if (force) rethrow;
    } finally {
      if (ref.mounted) state = false;
    }
  }
}
