/// The outcome of asking the device owner to confirm it's them.
enum DeviceAuthResult {
  success,

  /// The user dismissed the prompt, or the system interrupted it.
  canceled,

  /// The face, fingerprint or passcode didn't match.
  failed,

  /// Too many attempts. The device wants its passcode before trying again.
  lockedOut,

  /// No passcode, fingerprint or face is set up, so nobody can be verified.
  unavailable,
}

/// Confirms that the person holding the device is its owner.
abstract interface class DeviceAuthenticator {
  /// Shows the platform prompt with [reason]. Never throws: every outcome,
  /// including platform errors, is reported as a [DeviceAuthResult].
  Future<DeviceAuthResult> authenticate({required String reason});
}
