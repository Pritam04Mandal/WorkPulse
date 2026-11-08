import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/usage_models.dart';

abstract interface class UsageAccessGateway {
  Future<bool> isGranted();
  Future<void> openSettings();
  Future<List<RawUsageEvent>> queryEvents(int startMs, int endMs);
  Future<Map<String, String>> appLabels(List<String> packages);
  Future<List<InstalledApp>> launchableApps();

  /// Launchers, which aren't apps the user is "using".
  Future<Set<String>> homePackages();
}

class PlatformUsageAccessGateway implements UsageAccessGateway {
  const PlatformUsageAccessGateway();

  static const _channel = MethodChannel('com.workpulse.app/usage_access');

  @override
  Future<bool> isGranted() async =>
      await _channel.invokeMethod<bool>('isGranted') ?? false;

  @override
  Future<void> openSettings() => _channel.invokeMethod<void>('openSettings');

  @override
  Future<List<RawUsageEvent>> queryEvents(int startMs, int endMs) async {
    final raw = await _channel.invokeListMethod<Map<Object?, Object?>>(
      'queryEvents',
      {'start': startMs, 'end': endMs},
    );
    return [
      for (final event in raw ?? const <Map<Object?, Object?>>[])
        RawUsageEvent(
          event['package']! as String,
          UsageEventType.values[event['kind']! as int],
          event['time']! as int,
        ),
    ];
  }

  @override
  Future<Map<String, String>> appLabels(List<String> packages) async =>
      await _channel.invokeMapMethod<String, String>('appLabels', {
        'packages': packages,
      }) ??
      const {};

  @override
  Future<List<InstalledApp>> launchableApps() async {
    final raw = await _channel.invokeListMethod<Map<Object?, Object?>>(
      'launchableApps',
    );
    return [
      for (final app in raw ?? const <Map<Object?, Object?>>[])
        InstalledApp(app['package']! as String, app['label']! as String),
    ];
  }

  @override
  Future<Set<String>> homePackages() async =>
      (await _channel.invokeListMethod<String>('homePackages'))?.toSet() ??
      const {};
}

final usageAccessGatewayProvider = Provider<UsageAccessGateway>(
  (ref) => const PlatformUsageAccessGateway(),
);
