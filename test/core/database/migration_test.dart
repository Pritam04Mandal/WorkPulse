import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workpulse/core/database/app_database.dart';
import 'package:workpulse/core/domain/enums.dart';

import 'generated/schema.dart';

void main() {
  final verifier = SchemaVerifier(GeneratedHelper());

  test('every schema version has a committed dump', () {
    final current = AppDatabase(NativeDatabase.memory());
    addTearDown(current.close);
    for (var v = 1; v <= current.schemaVersion; v++) {
      expect(
        File('drift_schemas/workpulse/drift_schema_v$v.json').existsSync(),
        isTrue,
        reason: 'Run dart run drift_dev make-migrations for schema $v',
      );
    }
  });

  test('a new database matches the dumped schema', () async {
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, db.schemaVersion);
  });

  group('integrity', () {
    late AppDatabase db;
    final now = DateTime.utc(2026, 11, 8);

    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    Future<String> addSource() async {
      final row = await db
          .into(db.dataSources)
          .insertReturning(
            DataSourcesCompanion.insert(
              kind: SourceKind.github,
              status: SourceStatus.connected,
              connectedAt: now,
            ),
          );
      return row.id;
    }

    Future<String> addProject() async {
      final row = await db
          .into(db.projects)
          .insertReturning(
            ProjectsCompanion.insert(
              name: 'workpulse-app',
              colorHex: '#6EA8FE',
              origin: ProjectOrigin.manual,
              createdAt: now,
            ),
          );
      return row.id;
    }

    Future<void> addEvent(String source, {String? project, String? ext}) =>
        db.into(db.activityEvents).insert(
          ActivityEventsCompanion.insert(
            sourceId: source,
            kind: ActivityKind.commit,
            category: ActivityCategory.coding,
            title: 'Commit',
            startedAt: now,
            projectId: Value(project),
            externalId: Value(ext),
          ),
        );

    test('foreign keys are enforced', () async {
      await expectLater(addEvent('missing'), throwsA(isA<SqliteException>()));
    });

    test('deleting a source removes its events', () async {
      final source = await addSource();
      await addEvent(source);
      await db.delete(db.dataSources).go();
      expect(await db.select(db.activityEvents).get(), isEmpty);
    });

    test('deleting a project keeps its events, unassigned', () async {
      final source = await addSource();
      await addEvent(source, project: await addProject());
      await db.delete(db.projects).go();
      final events = await db.select(db.activityEvents).get();
      expect(events.single.projectId, isNull);
    });

    test('a re-imported external event is rejected', () async {
      final source = await addSource();
      await addEvent(source, ext: 'sha1');
      await expectLater(
        addEvent(source, ext: 'sha1'),
        throwsA(isA<SqliteException>()),
      );
    });

    test('settings round-trip', () async {
      await db.writeSetting('k', 'a');
      await db.writeSetting('k', 'b');
      expect(await db.readSetting('k'), 'b');
      await db.deleteSetting('k');
      expect(await db.readSetting('k'), isNull);
    });
  });
}
