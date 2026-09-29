part of 'approval_bloc.dart';

enum ApprovalError { authFailed, authLockedOut, authUnavailable, requestUnavailable, submitFailed }

sealed class ApprovalState extends Equatable {
  const ApprovalState();

  /// While true, the sheet can't be closed and both decisions are disabled.
  bool get isBusy => false;

  @override
  List<Object?> get props => [];
}

final class ApprovalIdle extends ApprovalState {
  const ApprovalIdle();
}

final class ApprovalAuthenticating extends ApprovalState {
  const ApprovalAuthenticating(this.decision);

  final PaymentStatus decision;

  @override
  bool get isBusy => true;

  @override
  List<Object?> get props => [decision];
}

final class ApprovalSubmitting extends ApprovalState {
  const ApprovalSubmitting(this.decision);

  final PaymentStatus decision;

  @override
  bool get isBusy => true;

  @override
  List<Object?> get props => [decision];
}

/// The decision was recorded. The sheet closes with [payment].
final class ApprovalSucceeded extends ApprovalState {
  const ApprovalSucceeded(this.payment);

  final Payment payment;

  @override
  bool get isBusy => true;

  @override
  List<Object?> get props => [payment];
}

final class ApprovalFailed extends ApprovalState {
  const ApprovalFailed(this.decision, this.error);

  final PaymentStatus decision;
  final ApprovalError error;

  @override
  List<Object?> get props => [decision, error];
}
