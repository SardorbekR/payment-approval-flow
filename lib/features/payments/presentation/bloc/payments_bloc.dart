import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payment_approval/features/payments/domain/models/payments_snapshot.dart';
import 'package:payment_approval/features/payments/domain/repositories/payments_repository.dart';

part 'payments_event.dart';
part 'payments_state.dart';

/// Keeps every payment screen in sync with the repository. One instance lives above the router, so
/// all screens agree
class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  PaymentsBloc({required PaymentsRepository repository})
    : _repository = repository,
      super(const PaymentsLoading()) {
    // A retry cancels the previous subscription instead of adding a second one
    on<LoadPayments>(_loadPayments, transformer: restartable());
  }

  final PaymentsRepository _repository;

  Future<void> _loadPayments(_, Emitter<PaymentsState> emit) async {
    if (state is! PaymentsLoading) emit(const PaymentsLoading());

    try {
      await _repository.load();
    } catch (error, stackTrace) {
      // Any failure must end on the retry screen, not an endless spinner
      addError(error, stackTrace);
      emit(const PaymentsError());
      return;
    }
    // A newer LoadPayments may have replaced this handler while loading
    if (emit.isDone) return;

    await emit.forEach(_repository.watch(), onData: PaymentsLoaded.new);
  }
}
