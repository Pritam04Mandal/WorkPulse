/// How a local profile is identified.
enum AuthProvider { google, microsoft, local }

/// Where activity comes from. Each source is connected and removed on its own.
enum SourceKind {
  androidUsage,
  github,
  githubEnterprise,
  gitlab,
  teams,
  browserExtension,
  desktopCompanion,
}

enum SourceStatus { connected, disconnected, error }

enum ActivityKind {
  appUsage,
  codingSession,
  aiSession,
  meeting,
  commit,
  pullRequest,
  issue,
  review,
  browsing,
}

enum ActivityCategory { coding, ai, meetings, other }

/// How an event ended up on a project.
enum AttributionState { none, inferred, confirmed, userSet }

enum ProjectOrigin { manual, repository, discovered }

enum RuleKind { app, path, site, repo, title }

enum ExclusionKind { app, site }

enum ReportPeriod { daily, weekly }

enum DeviceKind { browserExtension, desktopCompanion }
