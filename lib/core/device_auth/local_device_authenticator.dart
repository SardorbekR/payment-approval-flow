import 'package:local_auth/local_auth.dart';
import 'package:payment_approval/core/device_auth/device_authenticator.dart';

class LocalDeviceAuthenticator implements DeviceAuthenticator {
  LocalDeviceAuthenticator({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  @override
  Future<DeviceAuthResult> authenticate({required String reason}) async {
    try {
      final authenticated = await _localAuth.authenticate(localizedReason: reason);

      return authenticated ? DeviceAuthResult.success : DeviceAuthResult.failed;
    } on LocalAuthException catch (error) {
      return switch (error.code) {
        LocalAuthExceptionCode.userCanceled ||
        LocalAuthExceptionCode.systemCanceled ||
        LocalAuthExceptionCode.timeout ||
        LocalAuthExceptionCode.userRequestedFallback => DeviceAuthResult.canceled,
        LocalAuthExceptionCode.noCredentialsSet ||
        LocalAuthExceptionCode.noBiometricsEnrolled ||
        LocalAuthExceptionCode.noBiometricHardware => DeviceAuthResult.unavailable,
        LocalAuthExceptionCode.temporaryLockout ||
        LocalAuthExceptionCode.biometricLockout => DeviceAuthResult.lockedOut,
        // Includes codes a newer plugin version may add
        _ => DeviceAuthResult.failed,
      };
    } on Exception {
      return DeviceAuthResult.failed;
    }
  }
}
