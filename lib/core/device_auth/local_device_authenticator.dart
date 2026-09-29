import 'package:local_auth/local_auth.dart';
import 'package:payment_approval/core/device_auth/device_authenticator.dart';

/// Face ID, Touch ID or fingerprint through the platform, with the device
/// passcode as a fallback. It fails closed: anything short of a clear success
/// is reported as a failure of some kind.
class LocalDeviceAuthenticator implements DeviceAuthenticator {
  LocalDeviceAuthenticator({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  @override
  Future<DeviceAuthResult> authenticate({required String reason}) async {
    try {
      final authenticated = await _localAuth.authenticate(localizedReason: reason);

      // iOS reports a failed match as `false` rather than as an error.
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
        // Device errors, and any code a future plugin version adds.
        _ => DeviceAuthResult.failed,
      };
    } on Exception {
      // A platform channel failure, for example. Fail closed.
      return DeviceAuthResult.failed;
    }
  }
}
