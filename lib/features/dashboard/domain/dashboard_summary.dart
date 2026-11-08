import '../../../core/domain/enums.dart';

class CategoryTime {
  const CategoryTime(this.category, this.label, this.duration);

  final ActivityCategory category;
  final String label;
  final Duration duration;
}

enum DashboardDestination {
  timeline,
  projects,
  insights,
  github,
  integrations,
  journal,
}

class StatTile {
  const StatTile({
    required this.label,
    required this.value,
    required this.caption,
    required this.destination,
  });

  final String label;
  final String value;
  final String caption;
  final DashboardDestination destination;
}

enum RecentKind { coding, ai, meeting, github }

class RecentActivity {
  const RecentActivity({
    required this.entryId,
    required this.time,
    required this.kind,
    required this.title,
    required this.subtitle,
    this.duration,
  });

  /// The timeline event this row opens.
  final String entryId;
  final String time;
  final RecentKind kind;
  final String title;
  final String subtitle;

  /// Null for point events such as opening a pull request.
  final Duration? duration;
}

class DashboardSummary {
  const DashboardSummary({
    required this.isSample,
    required this.categories,
    required this.nowEntryId,
    required this.nowLabel,
    required this.nowDuration,
    required this.tiles,
    required this.recent,
    required this.dailySummary,
    required this.integrationsLabel,
  });

  /// True when the numbers are made up and must be labelled as such.
  final bool isSample;
  final List<CategoryTime> categories;
  final String nowEntryId;
  final String nowLabel;
  final Duration nowDuration;
  final List<StatTile> tiles;
  final List<RecentActivity> recent;
  final String dailySummary;
  final String integrationsLabel;

  Duration get activeTime =>
      categories.fold(Duration.zero, (sum, c) => sum + c.duration);
}
