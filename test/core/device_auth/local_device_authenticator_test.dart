import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:payment_approval/core/device_auth/device_authenticator.dart';
import 'package:payment_approval/core/device_auth/local_device_authenticator.dart';

class MockLocalAuthentication extends Mock implements LocalAuthentication {}

void main() {
  late MockLocalAuthentication localAuth;
  late LocalDeviceAuthenticator authenticator;

  void whenPlatformReturns(bool authenticated) {
    when(
      () => localAuth.authenticate(localizedReason: any(named: 'localizedReason')),
    ).thenAnswer((_) async => authenticated);
  }

  void whenPlatformThrows(LocalAuthExceptionCode code) {
    when(
      () => localAuth.authenticate(localizedReason: any(named: 'localizedReason')),
    ).thenThrow(LocalAuthException(code: code));
  }

  setUp(() {
    localAuth = MockLocalAuthentication();
    authenticator = LocalDeviceAuthenticator(localAuth: localAuth);
  });

  group('authenticate', () {
    test('shows the platform prompt with the given reason', () async {
      whenPlatformReturns(true);

      await authenticator.authenticate(reason: 'Confirm payment PAY-88213');

      verify(() => localAuth.authenticate(localizedReason: 'Confirm payment PAY-88213')).called(1);
    });

    test('reports success when the platform confirms the owner', () async {
      whenPlatformReturns(true);

      expect(await authenticator.authenticate(reason: 'reason'), DeviceAuthResult.success);
    });

    test('reports a failure when iOS answers false for a failed match', () async {
      whenPlatformReturns(false);

      expect(await authenticator.authenticate(reason: 'reason'), DeviceAuthResult.failed);
    });

    const expectations = {
      LocalAuthExceptionCode.userCanceled: DeviceAuthResult.cancelled,
      LocalAuthExceptionCode.systemCanceled: DeviceAuthResult.cancelled,
      LocalAuthExceptionCode.timeout: DeviceAuthResult.cancelled,
      LocalAuthExceptionCode.userRequestedFallback: DeviceAuthResult.cancelled,
      LocalAuthExceptionCode.noCredentialsSet: DeviceAuthResult.unavailable,
      LocalAuthExceptionCode.noBiometricsEnrolled: DeviceAuthResult.unavailable,
      LocalAuthExceptionCode.noBiometricHardware: DeviceAuthResult.unavailable,
      LocalAuthExceptionCode.temporaryLockout: DeviceAuthResult.lockedOut,
      LocalAuthExceptionCode.biometricLockout: DeviceAuthResult.lockedOut,
      LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable: DeviceAuthResult.failed,
      LocalAuthExceptionCode.authInProgress: DeviceAuthResult.failed,
      LocalAuthExceptionCode.uiUnavailable: DeviceAuthResult.failed,
      LocalAuthExceptionCode.deviceError: DeviceAuthResult.failed,
      LocalAuthExceptionCode.unknownError: DeviceAuthResult.failed,
    };

    for (final MapEntry(key: code, value: result) in expectations.entries) {
      test('turns ${code.name} into ${result.name}', () async {
        whenPlatformThrows(code);

        expect(await authenticator.authenticate(reason: 'reason'), result);
      });
    }

    test('covers every error code the plugin defines', () {
      expect(expectations.keys, unorderedEquals(LocalAuthExceptionCode.values));
    });
  });
}
