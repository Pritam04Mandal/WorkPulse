import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

enum AuthOutcome {
  success,

  /// Cancelled or not recognised. Trying again is fine.
  failed,

  /// The phone has no screen lock, so there's nothing to check against.
  unavailable,
}

abstract interface class BiometricGateway {
  Future<AuthOutcome> authenticate(String reason);
}

class LocalAuthGateway implements BiometricGateway {
  LocalAuthGateway([LocalAuthentication? auth])
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<AuthOutcome> authenticate(String reason) async {
    try {
      if (!await _auth.isDeviceSupported()) return AuthOutcome.unavailable;
      // Screen lock is allowed as a fallback, so a failing sensor or a
      // wet finger can never lock anyone out of their own data.
      final passed = await _auth.authenticate(
        localizedReason: reason,
        sensitiveTransaction: false,
      );
      return passed ? AuthOutcome.success : AuthOutcome.failed;
    } on LocalAuthException catch (error) {
      return error.code == LocalAuthExceptionCode.noCredentialsSet
          ? AuthOutcome.unavailable
          : AuthOutcome.failed;
    } on PlatformException {
      return AuthOutcome.failed;
    }
  }
}

final biometricGatewayProvider = Provider<BiometricGateway>(
  (ref) => LocalAuthGateway(),
);
