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
    // People type the name they see, like Chrome, not com.android.chrome.
    RuleKind.app =>
      activity.application?.toLowerCase() == value ||
          activity.title.toLowerCase() == value,
    RuleKind.title => activity.title.toLowerCase().contains(value),
    RuleKind.path => _folderOf(activity) == _lastPathPart(rule.value),
    // Needs the browser extension, which doesn't exist yet.
    RuleKind.site => false,
  };
}

const _systemPrefixes = [
  'android',
  'com.android.',
  'com.oneplus.',
  'com.oplus.',
  'com.coloros.',
  'com.heytap.',
  'com.nearme.',
  'com.samsung.android.',
  'com.sec.android.',
  'com.miui.',
  'com.xiaomi.',
  'com.huawei.',
  'com.vivo.',
  'com.motorola.',
  'co.aospa.',
  'net.pixelos.',
  'org.lineageos.',
];

const _googleSystemApps = {
  'com.google.android.dialer',
  'com.google.android.contacts',
  'com.google.android.apps.messaging',
  'com.google.android.deskclock',
  'com.google.android.calculator',
  'com.google.android.calendar',
  'com.google.android.documentsui',
  'com.google.android.apps.nbu.files',
  'com.google.android.apps.weather',
  'com.google.android.apps.wellbeing',
  'com.google.android.GoogleCamera',
  'com.google.android.permissioncontroller',
  'com.google.android.packageinstaller',
  'com.google.android.settings.intelligence',
  'com.google.android.gms',
};

// Ship with the system, but people use them as ordinary apps.
const _notSystemApps = {
  'com.android.chrome',
  'com.sec.android.app.sbrowser',
  'com.heytap.browser',
};

/// Built-in phone apps: Settings, Phone, Messages, Camera and so on.
bool isSystemApp(TrackedActivity activity) {
  final package = activity.application;
  if (activity.kind != ActivityKind.appUsage || package == null) return false;
  if (_notSystemApps.contains(package)) return false;
  return _googleSystemApps.contains(package) ||
      _systemPrefixes.any(package.startsWith);
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
    if (project.isDefault && isSystemApp(activity)) return project;
    if (project.rules.any((rule) => _matchesRule(rule, activity))) {
      return project;
    }
  }
  return null;
}
