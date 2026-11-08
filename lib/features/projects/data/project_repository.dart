import 'dart:async';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart' hide Project;
import '../../../core/domain/enums.dart';
import '../domain/project.dart';

class ProjectRepository {
  ProjectRepository({required AppDatabase database, this._clock = DateTime.now})
    : _db = database;

  final AppDatabase _db;
  final DateTime Function() _clock;

  /// Emits now and after every change. Built on a controller because a
  /// generator waiting on an idle stream can't be cancelled until it wakes.
  Stream<List<Project>> watchAll() {
    late final StreamController<List<Project>> controller;
    StreamSubscription<void>? updates;
    var latest = Future<void>.value();
    var active = true;

    void publish() {
      latest = latest.then((_) async {
        if (!active) return;
        try {
          final projects = await _load();
          if (active) controller.add(projects);
        } catch (error, stack) {
          // Closing the database mid-load is a StateError, and harmless here.
          if (active) controller.addError(error, stack);
        }
      });
    }

    controller = StreamController(
      onListen: () {
        publish();
        updates = _db
            .tableUpdates(
              TableUpdateQuery.onAllTables([_db.projects, _db.projectRules]),
            )
            .listen((_) => publish());
      },
      onCancel: () {
        active = false;
        return updates?.cancel();
      },
    );
    return controller.stream;
  }

  /// Keeps the built-in project present, including after a data wipe.
  Future<void> _ensureDefault() async {
    // Check first: every write wakes watchAll, so writing here would loop.
    final existing = await (_db.select(
      _db.projects,
    )..where((t) => t.id.equals(usageProjectId))).getSingleOrNull();
    if (existing != null) return;
    await _db
        .into(_db.projects)
        .insert(
          ProjectsCompanion.insert(
            id: const Value(usageProjectId),
            name: usageProjectName,
            colorHex: usageProjectColor,
            origin: ProjectOrigin.discovered,
            createdAt: _clock(),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<List<Project>> _load() async {
    await _ensureDefault();
    final rows =
        await (_db.select(_db.projects)
              ..where((t) => t.archivedAt.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();
    final rules = await _db.select(_db.projectRules).get();
    final projects = [
      for (final row in rows)
        Project(
          id: row.id,
          name: row.name,
          colorHex: row.colorHex,
          repository: row.repositoryUrl,
          rules: [
            for (final rule in rules)
              if (rule.projectId == row.id)
                ProjectRuleItem(rule.kind, rule.pattern),
          ],
        ),
    ];
    // Last, so a project of your own always wins a match.
    return [
      ...projects.where((p) => !p.isDefault),
      ...projects.where((p) => p.isDefault),
    ];
  }

  /// Creates the project, or updates it and replaces its rules.
  Future<void> save(Project project) => _db.transaction(() async {
    final now = _clock();
    await _db
        .into(_db.projects)
        .insert(
          ProjectsCompanion.insert(
            id: Value(project.id),
            name: project.name,
            colorHex: project.colorHex,
            repositoryUrl: Value(project.repository),
            origin: ProjectOrigin.manual,
            createdAt: now,
          ),
          onConflict: DoUpdate(
            (_) => ProjectsCompanion(
              name: Value(project.name),
              colorHex: Value(project.colorHex),
              repositoryUrl: Value(project.repository),
            ),
          ),
        );
    await (_db.delete(
      _db.projectRules,
    )..where((t) => t.projectId.equals(project.id))).go();
    await _db.batch(
      (batch) => batch.insertAll(_db.projectRules, [
        for (final rule in project.rules)
          ProjectRulesCompanion.insert(
            projectId: project.id,
            kind: rule.kind,
            pattern: rule.value,
            createdAt: now,
          ),
      ]),
    );
  });

  /// Activity stays; it simply no longer belongs to a project.
  Future<void> delete(String id) =>
      (_db.delete(_db.projects)..where((t) => t.id.equals(id))).go();
}
