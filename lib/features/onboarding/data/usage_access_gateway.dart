import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class UsageAccessGateway {
  Future<bool> isGranted();
  Future<void> openSettings();
}

class PlatformUsageAccessGateway implements UsageAccessGateway {
  const PlatformUsageAccessGateway();

  static const _channel = MethodChannel('com.workpulse.app/usage_access');

  @override
  Future<bool> isGranted() async =>
      await _channel.invokeMethod<bool>('isGranted') ?? false;

  @override
  Future<void> openSettings() => _channel.invokeMethod<void>('openSettings');
}

final usageAccessGatewayProvider = Provider<UsageAccessGateway>(
  (ref) => const PlatformUsageAccessGateway(),
);
