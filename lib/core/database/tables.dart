import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/enums.dart';

// The original spec (§6) was not available when this schema was written. Only
// `users` is defined by the build handoff; every other table is derived from
// the fields the design canvas displays. Reconcile against the spec if it
// resurfaces, using a schema migration.

mixin UuidPrimaryKey on Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// The local profile. Tokens never live here, only in secure storage.
@DataClassName('UserRow')
@TableIndex(
  name: 'users_provider_subject_idx',
  columns: {#provider, #subjectId},
  unique: true,
)
class Users extends Table with UuidPrimaryKey {
  TextColumn get provider => textEnum<AuthProvider>()();
  TextColumn get subjectId => text().nullable()();
  TextColumn get name => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get photoUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastLoginAt => dateTime()();
}

class Projects extends Table with UuidPrimaryKey {
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get colorHex => text().withLength(min: 7, max: 7)();
  TextColumn get repositoryUrl => text().nullable()();
  TextColumn get origin => textEnum<ProjectOrigin>()();

  /// Set when [origin] is discovered, from 0 to 1.
  RealColumn get confidence => real().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
}

@TableIndex(name: 'project_rules_project_idx', columns: {#projectId})
class ProjectRules extends Table with UuidPrimaryKey {
  TextColumn get projectId =>
      text().references(Projects, #id, onDelete: KeyAction.cascade)();
  TextColumn get kind => textEnum<RuleKind>()();
  TextColumn get pattern => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
}

/// A connected source. Secrets are held in secure storage, keyed by [id].
@TableIndex(name: 'data_sources_kind_idx', columns: {#kind})
class DataSources extends Table with UuidPrimaryKey {
  TextColumn get kind => textEnum<SourceKind>()();
  TextColumn get status => textEnum<SourceStatus>()();
  TextColumn get accountLabel => text().nullable()();

  /// Instance address for GitHub Enterprise and self-managed GitLab.
  TextColumn get host => text().nullable()();
  TextColumn get grantedScopes => text().nullable()();

  /// Opaque incremental-sync position.
  TextColumn get syncCursor => text().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get connectedAt => dateTime()();
}

@TableIndex(name: 'paired_devices_source_idx', columns: {#sourceId})
class PairedDevices extends Table with UuidPrimaryKey {
  TextColumn get sourceId =>
      text().references(DataSources, #id, onDelete: KeyAction.cascade)();
  TextColumn get kind => textEnum<DeviceKind>()();
  TextColumn get name => text()();

  /// Identifies this device's signing key. The key is in secure storage.
  TextColumn get publicKey => text()();
  DateTimeColumn get pairedAt => dateTime()();
  DateTimeColumn get lastSeenAt => dateTime().nullable()();
}

/// Remote repositories and which project each one feeds.
@TableIndex(
  name: 'tracked_repositories_source_name_idx',
  columns: {#sourceId, #fullName},
  unique: true,
)
@TableIndex(name: 'tracked_repositories_project_idx', columns: {#projectId})
class TrackedRepositories extends Table with UuidPrimaryKey {
  TextColumn get sourceId =>
      text().references(DataSources, #id, onDelete: KeyAction.cascade)();
  TextColumn get fullName => text()();
  TextColumn get projectId => text().nullable().references(
    Projects,
    #id,
    onDelete: KeyAction.setNull,
  )();
  BoolColumn get ignored => boolean().withDefault(const Constant(false))();
}

/// Consecutive events merged into one block of work.
@TableIndex(name: 'work_sessions_started_idx', columns: {#startedAt})
@TableIndex(name: 'work_sessions_project_idx', columns: {#projectId})
class WorkSessions extends Table with UuidPrimaryKey {
  TextColumn get projectId => text().nullable().references(
    Projects,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get category => textEnum<ActivityCategory>()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime()();
}

@TableIndex(name: 'activity_events_started_idx', columns: {#startedAt})
@TableIndex(name: 'activity_events_project_idx', columns: {#projectId})
@TableIndex(name: 'activity_events_session_idx', columns: {#sessionId})
@TableIndex(
  name: 'activity_events_source_external_idx',
  columns: {#sourceId, #externalId},
  unique: true,
)
class ActivityEvents extends Table with UuidPrimaryKey {
  TextColumn get sourceId =>
      text().references(DataSources, #id, onDelete: KeyAction.cascade)();

  /// The source's own ID, used to de-duplicate re-imports.
  TextColumn get externalId => text().nullable()();
  TextColumn get kind => textEnum<ActivityKind>()();
  TextColumn get category => textEnum<ActivityCategory>()();
  TextColumn get title => text()();
  TextColumn get application => text().nullable()();
  TextColumn get workspacePath => text().nullable()();
  TextColumn get domain => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();

  /// Null for point-in-time events such as a commit.
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get sessionId => text().nullable().references(
    WorkSessions,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get projectId => text().nullable().references(
    Projects,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get attribution => textEnum<AttributionState>().withDefault(
    Constant(AttributionState.none.name),
  )();

  /// Set when [attribution] is inferred, from 0 to 1.
  RealColumn get confidence => real().nullable()();
  TextColumn get attributionReason => text().nullable()();
  IntColumn get mergedEventCount => integer().withDefault(const Constant(1))();
  BoolColumn get isPrivate => boolean().withDefault(const Constant(false))();

  /// The user edited this event's times ("corrected by you").
  BoolColumn get isCorrected => boolean().withDefault(const Constant(false))();
}

/// Events the user deleted, so a later sync doesn't import them again.
class EventTombstones extends Table {
  TextColumn get sourceId =>
      text().references(DataSources, #id, onDelete: KeyAction.cascade)();
  TextColumn get externalId => text()();
  DateTimeColumn get deletedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {sourceId, externalId};
}

@TableIndex(
  name: 'exclusions_kind_value_idx',
  columns: {#kind, #value},
  unique: true,
)
class Exclusions extends Table with UuidPrimaryKey {
  TextColumn get kind => textEnum<ExclusionKind>()();

  /// A package name or a domain.
  TextColumn get value => text()();
  TextColumn get label => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

@TableIndex(
  name: 'reports_period_start_idx',
  columns: {#period, #periodStart},
  unique: true,
)
class Reports extends Table with UuidPrimaryKey {
  TextColumn get period => textEnum<ReportPeriod>()();
  DateTimeColumn get periodStart => dateTime()();

  /// Rule-based report body, as JSON.
  TextColumn get body => text()();
  DateTimeColumn get generatedAt => dateTime()();
}

/// Non-secret app preferences.
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
