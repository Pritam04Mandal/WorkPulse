import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/domain/enums.dart';
import '../features/auth/presentation/session_controller.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/insights/presentation/insights_screen.dart';
import '../features/integrations/presentation/claude_code_screen.dart';
import '../features/integrations/presentation/github_connect_screen.dart';
import '../features/integrations/presentation/integrations_screen.dart';
import '../features/integrations/presentation/pair_device_screen.dart';
import '../features/integrations/presentation/self_hosted_git_screen.dart';
import '../features/integrations/presentation/source_detail_screen.dart';
import '../features/integrations/presentation/teams_connect_screen.dart';
import '../features/journal/presentation/journal_screen.dart';
import '../features/onboarding/presentation/sign_in_screen.dart';
import '../features/onboarding/presentation/usage_access_screen.dart';
import '../features/onboarding/presentation/welcome_screen.dart';
import '../features/projects/presentation/project_detail_screen.dart';
import '../features/projects/presentation/project_form_screen.dart';
import '../features/projects/presentation/projects_screen.dart';
import '../features/settings/presentation/delete_data_screen.dart';
import '../features/settings/presentation/exclusions_screen.dart';
import '../features/settings/presentation/profile_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/timeline/presentation/activity_detail_screen.dart';
import '../features/timeline/presentation/timeline_screen.dart';
import 'app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

const _onboardingPrefixes = ['/welcome', '/sign-in', '/usage-access'];

/// Keeps unfinished users in onboarding. Finished users can still reach
/// sign-in and Usage Access, from Profile and Settings.
@visibleForTesting
String? onboardingRedirect({
  required bool onboardingComplete,
  required String location,
}) {
  final inOnboarding = _onboardingPrefixes.any(location.startsWith);
  if (!onboardingComplete && !inOnboarding) return '/welcome';
  if (onboardingComplete && location.startsWith('/welcome')) return '/home';
  return null;
}

/// A screen pushed over the bottom navigation.
GoRoute _pushed(String path, GoRouterWidgetBuilder builder) => GoRoute(
  path: path,
  parentNavigatorKey: _rootNavigatorKey,
  builder: builder,
);

StatefulShellBranch _tab(
  String path,
  Widget screen, [
  List<RouteBase> routes = const [],
]) => StatefulShellBranch(
  routes: [
    GoRoute(path: path, builder: (context, state) => screen, routes: routes),
  ],
);

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(
    sessionProvider.select((s) => s.onboardingComplete),
    (previous, next) => refresh.value++,
  );
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: refresh,
    redirect: (context, state) => onboardingRedirect(
      onboardingComplete: ref.read(sessionProvider).onboardingComplete,
      location: state.matchedLocation,
    ),
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/sign-in/:provider',
        builder: (context, state) => SignInScreen(
          provider: state.pathParameters['provider'] == 'microsoft'
              ? AuthProvider.microsoft
              : AuthProvider.google,
        ),
      ),
      GoRoute(
        path: '/usage-access',
        builder: (context, state) => const UsageAccessScreen(),
      ),
      GoRoute(
        path: '/activity/:id',
        builder: (context, state) =>
            ActivityDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/integrations',
        builder: (context, state) => const IntegrationsScreen(),
        routes: [
          GoRoute(
            path: 'github',
            builder: (context, state) => const SourceDetailScreen(),
            routes: [
              GoRoute(
                path: 'connect',
                builder: (context, state) => const GitHubConnectScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'claude',
            builder: (context, state) => const ClaudeCodeScreen(),
          ),
          GoRoute(
            path: 'vscode',
            builder: (context, state) =>
                const ClaudeCodeScreen(app: CompanionApp.vscode),
          ),
          GoRoute(
            path: 'teams',
            builder: (context, state) => const TeamsConnectScreen(),
          ),
          GoRoute(
            path: 'pair',
            builder: (context, state) => PairDeviceScreen(
              desktop: state.uri.queryParameters['device'] == 'desktop',
            ),
          ),
          GoRoute(
            path: 'add-git',
            builder: (context, state) => const SelfHostedGitScreen(),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          _tab('/home', const DashboardScreen(), [
            _pushed('journal', (context, state) => const JournalScreen()),
          ]),
          _tab('/timeline', const TimelineScreen()),
          _tab('/projects', const ProjectsScreen(), [
            _pushed('new', (context, state) => const ProjectFormScreen()),
            _pushed(
              ':id',
              (context, state) =>
                  ProjectDetailScreen(id: state.pathParameters['id']!),
            ),
            _pushed(
              ':id/edit',
              (context, state) =>
                  ProjectFormScreen(id: state.pathParameters['id']),
            ),
          ]),
          _tab('/insights', const InsightsScreen()),
          _tab('/settings', const SettingsScreen(), [
            _pushed('profile', (context, state) => const ProfileScreen()),
            _pushed(
              'exclusions',
              (context, state) => ExclusionsScreen(
                showSites: state.uri.queryParameters['tab'] == 'sites',
              ),
            ),
            _pushed(
              'delete-data',
              (context, state) => const DeleteDataScreen(),
            ),
          ]),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
