import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payment_approval/core/device_auth/device_authenticator.dart';
import 'package:payment_approval/features/payments/data/data_sources/payments_api.dart';
import 'package:payment_approval/features/payments/data/repositories/payments_repository.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';
import 'package:payment_approval/features/payments/domain/models/payment_request.dart';

part 'approval_event.dart';

part 'approval_state.dart';

/// Drives one approval sheet. A decision is only sent after device
/// authentication succeeds, and a retry authenticates again instead of reusing
/// an earlier result.
class ApprovalBloc extends Bloc<ApprovalEvent, ApprovalState> {
  ApprovalBloc({
    required PaymentRequest request,
    required PaymentsRepository repository,
    required DeviceAuthenticator authenticator,
  }) : _request = request,
       _repository = repository,
       _authenticator = authenticator,
       super(const ApprovalIdle()) {
    // Taps that arrive while a decision is in progress are dropped, so the
    // same request is never submitted twice.
    on<ApprovalSubmitted>(_onSubmitted, transformer: droppable());
  }

  final PaymentRequest _request;
  final PaymentsRepository _repository;
  final DeviceAuthenticator _authenticator;

  Future<void> _onSubmitted(ApprovalSubmitted event, Emitter<ApprovalState> emit) async {
    final decision = event.decision;
    emit(ApprovalAuthenticating(decision));

    // Whatever goes wrong below, the sheet must never stay stuck in a busy state:
    // it can't be closed while busy. Errors are still reported through addError.
    final DeviceAuthResult authResult;
    try {
      authResult = await _authenticator.authenticate(reason: event.authReason);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(ApprovalFailed(decision, ApprovalError.authFailed));
      return;
    }

    switch (authResult) {
      case DeviceAuthResult.success:
        break;
      case DeviceAuthResult.cancelled:
        emit(const ApprovalIdle());
        return;
      case DeviceAuthResult.failed:
        emit(ApprovalFailed(decision, ApprovalError.authFailed));
        return;
      case DeviceAuthResult.lockedOut:
        emit(ApprovalFailed(decision, ApprovalError.authLockedOut));
        return;
      case DeviceAuthResult.unavailable:
        emit(ApprovalFailed(decision, ApprovalError.authUnavailable));
        return;
    }

    emit(ApprovalSubmitting(decision));
    try {
      emit(ApprovalSucceeded(await _repository.decide(_request, decision)));
    } on RequestUnavailableException {
      emit(ApprovalFailed(decision, ApprovalError.requestUnavailable));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(ApprovalFailed(decision, ApprovalError.submitFailed));
    }
  }
}
