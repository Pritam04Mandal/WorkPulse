import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class CompanionSecrets {
  Future<String?> read(String deviceId);
  Future<void> save(String deviceId, String secret);
  Future<void> delete(String deviceId);
  Future<void> clear();
}

class SecureCompanionSecrets implements CompanionSecrets {
  const SecureCompanionSecrets([this._storage = const FlutterSecureStorage()]);

  static const _prefix = 'companion.secret.';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String deviceId) =>
      _storage.read(key: '$_prefix$deviceId');

  @override
  Future<void> save(String deviceId, String secret) =>
      _storage.write(key: '$_prefix$deviceId', value: secret);

  @override
  Future<void> delete(String deviceId) =>
      _storage.delete(key: '$_prefix$deviceId');

  @override
  Future<void> clear() async {
    final all = await _storage.readAll();
    for (final key in all.keys.where((k) => k.startsWith(_prefix))) {
      await _storage.delete(key: key);
    }
  }
}

final companionSecretsProvider = Provider<CompanionSecrets>(
  (ref) => const SecureCompanionSecrets(),
);
