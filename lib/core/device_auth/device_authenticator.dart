enum DeviceAuthResult {
  success,
  canceled,
  failed,
  lockedOut,

  /// No screen lock or biometrics set up
  unavailable,
}

abstract interface class DeviceAuthenticator {
  /// Never throws. Every outcome is a [DeviceAuthResult]
  Future<DeviceAuthResult> authenticate({required String reason});
}
