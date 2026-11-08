import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

import '../domain/enums.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    Projects,
    ProjectRules,
    DataSources,
    PairedDevices,
    TrackedRepositories,
    WorkSessions,
    ActivityEvents,
    EventTombstones,
    Exclusions,
    Reports,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  factory AppDatabase.onDevice() =>
      AppDatabase(driftDatabase(name: 'workpulse'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    // To change the schema: edit tables.dart, bump schemaVersion, run
    // `dart run drift_dev make-migrations`, then replace this with the
    // generated stepByStep(...).
    onUpgrade: (m, from, to) async {
      throw UnsupportedError('No migration from schema $from to $to');
    },
    beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
  );

  Future<String?> readSetting(String key) async {
    final row = await (select(
      appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> writeSetting(String key, String value) =>
      into(appSettings)
          .insertOnConflictUpdate(AppSetting(key: key, value: value));

  Future<void> deleteSetting(String key) =>
      (delete(appSettings)..where((t) => t.key.equals(key))).go();
}
