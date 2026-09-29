part of 'approval_bloc.dart';

sealed class ApprovalEvent {
  const ApprovalEvent();
}

/// The user chose to approve or reject. [authReason] is shown in the device prompt.
final class ApprovalSubmitted extends ApprovalEvent {
  const ApprovalSubmitted(this.decision, {required this.authReason});

  final PaymentStatus decision;
  final String authReason;
}
