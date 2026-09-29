import 'dart:async';

import 'package:payment_approval/core/device_auth/device_authenticator.dart';

/// Answers device prompts with [answer], or holds the next one open until the test answers it
class FakeDeviceAuthenticator implements DeviceAuthenticator {
  FakeDeviceAuthenticator({this.answer = DeviceAuthResult.success});

  DeviceAuthResult answer;

  /// The reason shown for every prompt, in order
  final reasons = <String>[];

  Completer<DeviceAuthResult>? _heldPrompt;

  void holdNextPrompt() => _heldPrompt = Completer<DeviceAuthResult>();

  void answerHeldPrompt(DeviceAuthResult result) {
    _heldPrompt?.complete(result);
    _heldPrompt = null;
  }

  @override
  Future<DeviceAuthResult> authenticate({required String reason}) {
    reasons.add(reason);

    return _heldPrompt?.future ?? Future.value(answer);
  }
}
