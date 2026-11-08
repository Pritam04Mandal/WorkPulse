import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/session_controller.dart';
import '../../tracking/domain/usage_models.dart';
import '../../tracking/presentation/tracking_controller.dart';
import '../data/project_repository.dart';
import '../domain/project.dart';
import '../domain/project_matcher.dart';

final projectRepositoryProvider = Provider<ProjectRepository>(
  (ref) => ProjectRepository(database: ref.watch(databaseProvider)),
);

final projectsProvider = StreamProvider<List<Project>>(
  (ref) => ref.watch(projectRepositoryProvider).watchAll(),
);

(DateTime, DateTime) currentWeekRange() {
  final start = startOfWeek(DateTime.now());
  return (start, DateTime(start.year, start.month, start.day + 7));
}

/// Each project's statistics for this week, by project ID.
final projectWeekStatsProvider =
    Provider.autoDispose<Map<String, ProjectStats>>((ref) {
      final projects = ref.watch(projectsProvider).value ?? const <Project>[];
      final range = currentWeekRange();
      final activities =
          ref.watch(rangeActivitiesProvider(range)).value ??
          const <TrackedActivity>[];
      final grouped = <String, List<TrackedActivity>>{};
      for (final activity in activities) {
        final project = matchProject(activity, projects);
        if (project != null) {
          (grouped[project.id] ??= []).add(activity);
        }
      }
      return {
        for (final project in projects)
          project.id: ProjectStats.from(
            grouped[project.id] ?? const [],
            range.$1,
          ),
      };
    });
