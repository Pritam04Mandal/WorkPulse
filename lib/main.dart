import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/auth_config.dart';
import 'core/database/app_database.dart';
import 'core/database/setting_keys.dart';
import 'core/domain/enums.dart';
import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/data/google_identity_provider.dart';
import 'features/auth/data/microsoft_identity_provider.dart';
import 'features/auth/data/secure_token_store.dart';
import 'features/auth/presentation/session_controller.dart';
import 'features/security/presentation/app_lock.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerFontLicenses();

  final database = AppDatabase.onDevice();
  const config = AuthConfig();
  final repository = AuthRepositoryImpl(
    database: database,
    tokens: const SecureTokenStore(),
    providers: {
      AuthProvider.google: GoogleIdentityProvider(config),
      AuthProvider.microsoft: MicrosoftIdentityProvider(config),
    },
  );
  final initial = await loadSession(database, repository);

  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(database),
      authRepositoryProvider.overrideWithValue(repository),
      initialSessionProvider.overrideWithValue(initial),
      initialLockEnabledProvider.overrideWithValue(
        await database.readSetting(biometricLockSettingKey) == 'true',
      ),
    ],
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const WorkPulseApp(),
    ),
  );

  // A failed refresh must not affect startup; the saved profile still works.
  unawaited(
    container
        .read(sessionProvider.notifier)
        .restore()
        .catchError((Object _) {}),
  );
}

void _registerFontLicenses() {
  for (final (package, asset) in const [
    ('Inter', 'assets/fonts/Inter-OFL.txt'),
    ('JetBrains Mono', 'assets/fonts/JetBrainsMono-OFL.txt'),
  ]) {
    LicenseRegistry.addLicense(() async* {
      yield LicenseEntryWithLineBreaks([
        package,
      ], await rootBundle.loadString(asset));
    });
  }
}
