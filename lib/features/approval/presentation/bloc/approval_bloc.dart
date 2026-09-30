import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payment_approval/core/device_auth/device_authenticator.dart';
import 'package:payment_approval/features/payments/data/data_sources/payments_data_source.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';
import 'package:payment_approval/features/payments/domain/models/payment_request.dart';
import 'package:payment_approval/features/payments/domain/repositories/payments_repository.dart';

part 'approval_event.dart';
part 'approval_state.dart';

class ApprovalBloc extends Bloc<ApprovalEvent, ApprovalState> {
  ApprovalBloc({
    required PaymentRequest request,
    required PaymentsRepository repository,
    required DeviceAuthenticator authenticator,
  }) : _request = request,
       _repository = repository,
       _authenticator = authenticator,
       super(const ApprovalInitial()) {
    // Ignores taps while a decision is running, so it's never sent twice
    on<SubmitDecision>(_submitDecision, transformer: droppable());
  }

  final PaymentRequest _request;
  final PaymentsRepository _repository;
  final DeviceAuthenticator _authenticator;

  Future<void> _submitDecision(SubmitDecision event, Emitter<ApprovalState> emit) async {
    final decision = event.decision;
    emit(ApprovalAuthenticating(decision));

    // The sheet can't close while busy, so every failure must end in a state the user can leave
    final DeviceAuthResult authResult;
    try {
      authResult = await _authenticator.authenticate(reason: event.authReason);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(ApprovalError(decision, ApprovalErrorReason.authFailed));
      return;
    }

    switch (authResult) {
      case DeviceAuthResult.success:
        break;
      case DeviceAuthResult.canceled:
        emit(const ApprovalInitial());
        return;
      case DeviceAuthResult.failed:
        emit(ApprovalError(decision, ApprovalErrorReason.authFailed));
        return;
      case DeviceAuthResult.lockedOut:
        emit(ApprovalError(decision, ApprovalErrorReason.authLockedOut));
        return;
      case DeviceAuthResult.unavailable:
        emit(ApprovalError(decision, ApprovalErrorReason.authUnavailable));
        return;
    }

    emit(ApprovalSubmitting(decision));
    try {
      emit(ApprovalSuccess(await _repository.decide(_request, decision)));
    } on RequestUnavailableException {
      emit(ApprovalError(decision, ApprovalErrorReason.requestUnavailable));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(ApprovalError(decision, ApprovalErrorReason.submitFailed));
    }
  }
}
