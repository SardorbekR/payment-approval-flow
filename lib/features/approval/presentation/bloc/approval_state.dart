part of 'approval_bloc.dart';

enum ApprovalErrorReason {
  authFailed,
  authLockedOut,
  authUnavailable,
  requestUnavailable,
  submitFailed,
}

sealed class ApprovalState extends Equatable {
  const ApprovalState();

  /// While true, the sheet can't be closed and both decisions are disabled.
  bool get isBusy => false;

  @override
  List<Object?> get props => [];
}

class ApprovalInitial extends ApprovalState {
  const ApprovalInitial();
}

class ApprovalAuthenticating extends ApprovalState {
  const ApprovalAuthenticating(this.decision);

  final PaymentStatus decision;

  @override
  bool get isBusy => true;

  @override
  List<Object?> get props => [decision];
}

class ApprovalSubmitting extends ApprovalState {
  const ApprovalSubmitting(this.decision);

  final PaymentStatus decision;

  @override
  bool get isBusy => true;

  @override
  List<Object?> get props => [decision];
}

/// The decision was recorded. The sheet closes with [payment].
class ApprovalSuccess extends ApprovalState {
  const ApprovalSuccess(this.payment);

  final Payment payment;

  @override
  bool get isBusy => true;

  @override
  List<Object?> get props => [payment];
}

class ApprovalError extends ApprovalState {
  const ApprovalError(this.decision, this.reason);

  final PaymentStatus decision;
  final ApprovalErrorReason reason;

  @override
  List<Object?> get props => [decision, reason];
}
