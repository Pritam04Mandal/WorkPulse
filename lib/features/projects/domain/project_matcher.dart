import '../../../core/domain/enums.dart';
import '../../tracking/domain/usage_models.dart';
import 'project.dart';

/// `github.com/owner/name.git` and similar, reduced to `owner/name`.
String normalizeRepository(String value) {
  final parts = value
      .trim()
      .toLowerCase()
      .replaceFirst(RegExp(r'^[a-z]+://'), '')
      .replaceFirst(RegExp(r'\.git/?$'), '')
      .replaceAll(':', '/')
      .split('/')
      .where((part) => part.isNotEmpty)
      .toList();
  return parts.skip(parts.length < 2 ? 0 : parts.length - 2).join('/');
}

/// The folder a session ran in, from a title like `VS Code · my-app`.
String? _folderOf(TrackedActivity activity) {
  if (activity.kind != ActivityKind.aiSession &&
      activity.kind != ActivityKind.codingSession) {
    return null;
  }
  final parts = activity.title.split(' · ');
  return parts.length > 1 ? parts.last.toLowerCase() : null;
}

String _lastPathPart(String pattern) => pattern
    .replaceAll(RegExp(r'/\*+$'), '')
    .replaceAll(RegExp(r'/$'), '')
    .split('/')
    .last
    .toLowerCase();

bool _matchesRule(ProjectRuleItem rule, TrackedActivity activity) {
  final value = rule.value.trim().toLowerCase();
  if (value.isEmpty) return false;
  return switch (rule.kind) {
    RuleKind.repo =>
      activity.repository?.toLowerCase() == normalizeRepository(rule.value),
    RuleKind.app => activity.application?.toLowerCase() == value,
    RuleKind.title => activity.title.toLowerCase().contains(value),
    RuleKind.path => _folderOf(activity) == _lastPathPart(rule.value),
    // Needs the browser extension, which doesn't exist yet.
    RuleKind.site => false,
  };
}

/// The first project this activity belongs to. Private events belong to none.
Project? matchProject(TrackedActivity activity, List<Project> projects) {
  if (activity.isPrivate) return null;
  for (final project in projects) {
    if (activity.projectId == project.id) return project;
    final repository = project.repository;
    if (repository != null &&
        activity.repository?.toLowerCase() == normalizeRepository(repository)) {
      return project;
    }
    if (project.rules.any((rule) => _matchesRule(rule, activity))) {
      return project;
    }
  }
  return null;
}
