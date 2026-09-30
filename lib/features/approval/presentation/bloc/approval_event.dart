part of 'approval_bloc.dart';

sealed class ApprovalEvent {
  const ApprovalEvent();
}

class SubmitDecision extends ApprovalEvent {
  const SubmitDecision(this.decision, {required this.authReason});

  final PaymentStatus decision;
  final String authReason;
}
