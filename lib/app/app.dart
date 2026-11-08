import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/github/presentation/github_controller.dart';
import '../features/tracking/presentation/tracking_controller.dart';
import 'router.dart';

class WorkPulseApp extends ConsumerStatefulWidget {
  const WorkPulseApp({super.key});

  @override
  ConsumerState<WorkPulseApp> createState() => _WorkPulseAppState();
}

class _WorkPulseAppState extends ConsumerState<WorkPulseApp> {
  late final AppLifecycleListener _lifecycle;

  GitHubSync get _github => ref.read(githubSyncProvider.notifier);

  void _catchUp() {
    ref.read(trackingControllerProvider.notifier).refresh();
    ref.read(githubSyncProvider.notifier).refresh();
  }

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () {
        _catchUp();
        _github.startLive();
      },
      onHide: () => _github.stopLive(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _catchUp();
      _github.startLive();
    });
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'WorkPulse',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.dark,
    routerConfig: ref.watch(routerProvider),
  );
}
