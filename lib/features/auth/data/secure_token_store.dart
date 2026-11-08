import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/domain/enums.dart';
import '../domain/auth_contracts.dart';

class SecureTokenStore implements TokenStore {
  const SecureTokenStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  String _key(AuthProvider provider) => 'auth.${provider.name}.id_token';

  @override
  Future<void> saveIdToken(AuthProvider provider, String? token) =>
      token == null
      ? clear(provider)
      : _storage.write(key: _key(provider), value: token);

  @override
  Future<void> clear(AuthProvider provider) =>
      _storage.delete(key: _key(provider));
}
