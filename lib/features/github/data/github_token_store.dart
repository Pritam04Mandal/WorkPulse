import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class GitHubTokenStore {
  Future<String?> read();
  Future<void> save(String token);
  Future<void> clear();
}

class SecureGitHubTokenStore implements GitHubTokenStore {
  const SecureGitHubTokenStore([this._storage = const FlutterSecureStorage()]);

  static const _key = 'source.github.token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> save(String token) => _storage.write(key: _key, value: token);

  @override
  Future<void> clear() => _storage.delete(key: _key);
}

final githubTokenStoreProvider = Provider<GitHubTokenStore>(
  (ref) => const SecureGitHubTokenStore(),
);
