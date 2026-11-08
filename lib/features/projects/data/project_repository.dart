import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart' hide Project;
import '../../../core/domain/enums.dart';
import '../domain/project.dart';

class ProjectRepository {
  ProjectRepository({required AppDatabase database, this._clock = DateTime.now})
    : _db = database;

  final AppDatabase _db;
  final DateTime Function() _clock;

  Stream<List<Project>> watchAll() async* {
    yield await _load();
    await for (final _ in _db.tableUpdates(
      TableUpdateQuery.onAllTables([_db.projects, _db.projectRules]),
    )) {
      yield await _load();
    }
  }

  Future<List<Project>> _load() async {
    final rows =
        await (_db.select(_db.projects)
              ..where((t) => t.archivedAt.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();
    final rules = await _db.select(_db.projectRules).get();
    return [
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
