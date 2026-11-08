import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/domain/enums.dart';
import '../core/widgets/placeholder_screen.dart';
import '../features/auth/presentation/session_controller.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/onboarding/presentation/sign_in_screen.dart';
import '../features/onboarding/presentation/usage_access_screen.dart';
import '../features/onboarding/presentation/welcome_screen.dart';
import 'app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

const _onboardingPrefixes = ['/welcome', '/sign-in', '/usage-access'];

/// Keeps unfinished users in onboarding and finished users out of it.
@visibleForTesting
String? onboardingRedirect({
  required bool onboardingComplete,
  required String location,
}) {
  final inOnboarding = _onboardingPrefixes.any(location.startsWith);
  if (!onboardingComplete && !inOnboarding) return '/welcome';
  if (onboardingComplete && inOnboarding) return '/home';
  return null;
}

StatefulShellBranch _tab(String path, String title) => StatefulShellBranch(
  routes: [
    GoRoute(
      path: path,
      builder: (context, state) => PlaceholderScreen(title: title),
    ),
  ],
);

GoRoute _pushedPlaceholder(String path, String title) => GoRoute(
  path: path,
  parentNavigatorKey: _rootNavigatorKey,
  builder: (context, state) => PlaceholderScreen(title: title, showBack: true),
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const DashboardScreen(),
                routes: [
                  _pushedPlaceholder('journal', 'Daily work journal'),
                  _pushedPlaceholder('integrations', 'Integrations'),
                ],
              ),
            ],
          ),
          _tab('/timeline', 'Timeline'),
          _tab('/projects', 'Projects'),
          _tab('/insights', 'Insights'),
          _tab('/settings', 'Settings'),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
