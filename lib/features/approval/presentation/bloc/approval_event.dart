part of 'approval_bloc.dart';

sealed class ApprovalEvent {
  const ApprovalEvent();
}

/// The user chose to approve or reject. [authReason] is shown in the device prompt
class SubmitDecision extends ApprovalEvent {
  const SubmitDecision(this.decision, {required this.authReason});

  final PaymentStatus decision;
  final String authReason;
}
