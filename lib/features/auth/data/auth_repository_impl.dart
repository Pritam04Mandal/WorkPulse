import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/domain/enums.dart';
import '../domain/auth_contracts.dart';
import '../domain/auth_models.dart';

const currentUserSettingKey = 'current_user_id';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AppDatabase database,
    required this._providers,
    required this._tokens,
    this._clock = DateTime.now,
  }) : _db = database;

  final AppDatabase _db;
  final Map<AuthProvider, IdentityProvider> _providers;
  final TokenStore _tokens;
  final DateTime Function() _clock;

  @override
  Future<UserProfile?> currentUser() async =>
      (await _currentRow())?.toProfile();

  @override
  Future<UserProfile> signIn(AuthProvider provider) async {
    final idp = _providers[provider];
    if (idp == null) throw const AuthFailure(AuthFailureKind.notConfigured);
    final identity = await idp.signIn();
    final row = await _saveIdentity(provider, identity);
    await _tokens.saveIdToken(provider, identity.idToken);
    return row.toProfile();
  }

  @override
  Future<UserProfile> continueWithoutAccount() => _db.transaction(() async {
    final now = _clock();
    final existing =
        await (_db.select(_db.users)
              ..where((t) => t.provider.equalsValue(AuthProvider.local)))
            .getSingleOrNull();
    final row =
        existing ??
        await _db
            .into(_db.users)
            .insertReturning(
              UsersCompanion.insert(
                provider: AuthProvider.local,
                createdAt: now,
                lastLoginAt: now,
              ),
            );
    await _db.writeSetting(currentUserSettingKey, row.id);
    return row.toProfile();
  });

  @override
  Future<UserProfile?> restoreSession() async {
    final row = await _currentRow();
    if (row == null || row.provider == AuthProvider.local) {
      return row?.toProfile();
    }
    final identity = await _providers[row.provider]?.restore();
    if (identity == null || identity.subjectId != row.subjectId) {
      return row.toProfile();
    }
    final updated = await _saveIdentity(row.provider, identity);
    await _tokens.saveIdToken(row.provider, identity.idToken);
    return updated.toProfile();
  }

  @override
  Future<void> signOut() async {
    final row = await _currentRow();
    if (row == null) return;
    await _providers[row.provider]?.signOut();
    await _tokens.clear(row.provider);
    await _db.deleteSetting(currentUserSettingKey);
  }

  @override
  Future<void> deleteAllLocalData() async {
    for (final MapEntry(key: kind, value: provider) in _providers.entries) {
      try {
        await provider.signOut();
      } on Exception {
        // A provider or network failure must not block deleting local data.
      }
      await _tokens.clear(kind);
    }
    await _db.transaction(() async {
      for (final TableInfo table in _db.allTables) {
        await _db.delete(table).go();
      }
    });
  }

  Future<UserRow?> _currentRow() async {
    final id = await _db.readSetting(currentUserSettingKey);
    if (id == null) return null;
    return (_db.select(
      _db.users,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Keeps one row per provider account. Signing in from a local profile
  /// upgrades that row, so its local ID and creation date survive.
  Future<UserRow> _saveIdentity(
    AuthProvider provider,
    ProviderIdentity identity,
  ) => _db.transaction(() async {
    final now = _clock();
    final profile = UsersCompanion(
      provider: Value(provider),
      subjectId: Value(identity.subjectId),
      name: Value(identity.name),
      email: Value(identity.email),
      photoUrl: Value(identity.photoUrl),
      lastLoginAt: Value(now),
    );

    final current = await _currentRow();
    final localCurrent = current?.provider == AuthProvider.local
        ? current
        : null;
    final known =
        await (_db.select(_db.users)..where(
              (t) =>
                  t.provider.equalsValue(provider) &
                  t.subjectId.equals(identity.subjectId),
            ))
            .getSingleOrNull();

    final UserRow saved;
    if (known != null) {
      saved = await _update(known.id, profile);
      if (localCurrent != null) {
        await (_db.delete(
          _db.users,
        )..where((t) => t.id.equals(localCurrent.id))).go();
      }
    } else if (localCurrent != null) {
      saved = await _update(localCurrent.id, profile);
    } else {
      saved = await _db
          .into(_db.users)
          .insertReturning(profile.copyWith(createdAt: Value(now)));
    }
    await _db.writeSetting(currentUserSettingKey, saved.id);
    return saved;
  });

  Future<UserRow> _update(String id, UsersCompanion values) async {
    final rows = await (_db.update(
      _db.users,
    )..where((t) => t.id.equals(id))).writeReturning(values);
    return rows.single;
  }
}

extension on UserRow {
  UserProfile toProfile() => UserProfile(
    id: id,
    provider: provider,
    subjectId: subjectId,
    name: name,
    email: email,
    photoUrl: photoUrl,
    createdAt: createdAt,
    lastLoginAt: lastLoginAt,
  );
}
