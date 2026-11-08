import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workpulse/core/database/app_database.dart';
import 'package:workpulse/core/domain/enums.dart';
import 'package:workpulse/features/auth/data/auth_repository_impl.dart';
import 'package:workpulse/features/auth/domain/auth_contracts.dart';
import 'package:workpulse/features/auth/domain/auth_models.dart';

class FakeProvider implements IdentityProvider {
  ProviderIdentity? next;
  AuthFailure? failure;
  ProviderIdentity? restored;
  bool signedOut = false;

  @override
  bool get isConfigured => true;

  @override
  Future<ProviderIdentity> signIn() async {
    if (failure != null) throw failure!;
    return next!;
  }

  @override
  Future<ProviderIdentity?> restore() async => restored;

  @override
  Future<void> signOut() async => signedOut = true;
}

class FakeTokens implements TokenStore {
  final saved = <AuthProvider, String?>{};

  @override
  Future<void> saveIdToken(AuthProvider provider, String? token) async =>
      saved[provider] = token;

  @override
  Future<void> clear(AuthProvider provider) async => saved.remove(provider);
}

void main() {
  late AppDatabase db;
  late FakeProvider google;
  late FakeTokens tokens;
  late AuthRepositoryImpl repo;
  var now = DateTime.utc(2026, 11, 8, 9);

  const ada = ProviderIdentity(
    subjectId: 'sub-1',
    name: 'Ada',
    email: 'ada@example.com',
    idToken: 'secret-token',
  );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    google = FakeProvider()..next = ada;
    tokens = FakeTokens();
    repo = AuthRepositoryImpl(
      database: db,
      providers: {AuthProvider.google: google},
      tokens: tokens,
      clock: () => now,
    );
  });
  tearDown(() => db.close());

  test('sign-in stores the profile, with the token kept out of it', () async {
    final user = await repo.signIn(AuthProvider.google);

    expect(user.subjectId, 'sub-1');
    expect(user.email, 'ada@example.com');
    expect(tokens.saved[AuthProvider.google], 'secret-token');

    final dump = await db
        .customSelect('SELECT * FROM users')
        .map((r) => r.data.toString())
        .get();
    expect(dump.join(), isNot(contains('secret-token')));
    expect((await repo.currentUser())?.id, user.id);
  });

  test('signing in again updates the same row', () async {
    final first = await repo.signIn(AuthProvider.google);
    now = now.add(const Duration(days: 1));
    google.next = const ProviderIdentity(subjectId: 'sub-1', name: 'Ada L');

    final second = await repo.signIn(AuthProvider.google);

    expect(second.id, first.id);
    expect(second.name, 'Ada L');
    expect(second.createdAt, first.createdAt);
    expect(second.lastLoginAt.isAtSameMomentAs(now), isTrue);
    expect(await db.select(db.users).get(), hasLength(1));
  });

  test('signing in from a local profile keeps its local ID', () async {
    final local = await repo.continueWithoutAccount();
    final user = await repo.signIn(AuthProvider.google);

    expect(user.id, local.id);
    expect(user.provider, AuthProvider.google);
    expect(await db.select(db.users).get(), hasLength(1));
  });

  test('a local profile merges into an already known account', () async {
    final known = await repo.signIn(AuthProvider.google);
    await repo.signOut();
    await repo.continueWithoutAccount();

    final user = await repo.signIn(AuthProvider.google);

    expect(user.id, known.id);
    expect(await db.select(db.users).get(), hasLength(1));
  });

  test('continuing without an account reuses the local row', () async {
    final first = await repo.continueWithoutAccount();
    final second = await repo.continueWithoutAccount();

    expect(second.id, first.id);
    expect(first.isLocal, isTrue);
    expect(first.subjectId, isNull);
  });

  test('a failed sign-in saves nothing', () async {
    google.failure = const AuthFailure(AuthFailureKind.cancelled);

    await expectLater(
      repo.signIn(AuthProvider.google),
      throwsA(
        isA<AuthFailure>().having(
          (f) => f.kind,
          'kind',
          AuthFailureKind.cancelled,
        ),
      ),
    );
    expect(await db.select(db.users).get(), isEmpty);
    expect(tokens.saved, isEmpty);
  });

  test('an unregistered provider reports not configured', () async {
    await expectLater(
      repo.signIn(AuthProvider.microsoft),
      throwsA(
        isA<AuthFailure>().having(
          (f) => f.kind,
          'kind',
          AuthFailureKind.notConfigured,
        ),
      ),
    );
  });

  test('sign-out clears the token and session but keeps the row', () async {
    await repo.signIn(AuthProvider.google);
    await repo.signOut();

    expect(google.signedOut, isTrue);
    expect(tokens.saved, isEmpty);
    expect(await repo.currentUser(), isNull);
    expect(await db.select(db.users).get(), hasLength(1));
  });

  test('restore refreshes the profile and token', () async {
    await repo.signIn(AuthProvider.google);
    google.restored = const ProviderIdentity(
      subjectId: 'sub-1',
      name: 'Ada R',
      idToken: 'fresh',
    );

    final user = await repo.restoreSession();

    expect(user?.name, 'Ada R');
    expect(tokens.saved[AuthProvider.google], 'fresh');
  });

  test('restore ignores a different account', () async {
    await repo.signIn(AuthProvider.google);
    google.restored = const ProviderIdentity(subjectId: 'other', name: 'Eve');

    final user = await repo.restoreSession();

    expect(user?.name, 'Ada');
    expect(tokens.saved[AuthProvider.google], 'secret-token');
  });

  test('identities and failures never print tokens', () {
    expect(ada.toString(), isNot(contains('secret-token')));
  });
}
