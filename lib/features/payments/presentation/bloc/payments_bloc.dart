import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payment_approval/features/payments/data/repositories/payments_repository.dart';
import 'package:payment_approval/features/payments/domain/models/payments_snapshot.dart';

part 'payments_event.dart';

part 'payments_state.dart';

/// Keeps every payment screen in sync with the repository. A single instance
/// lives above the router, so Home, Payments and details always agree.
class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  PaymentsBloc({required PaymentsRepository repository})
    : _repository = repository,
      super(const PaymentsLoading()) {
    // A retry cancels the previous subscription instead of adding a second one.
    on<PaymentsStarted>(_onStarted, transformer: restartable());
  }

  final PaymentsRepository _repository;

  Future<void> _onStarted(PaymentsStarted event, Emitter<PaymentsState> emit) async {
    if (state is! PaymentsLoading) emit(const PaymentsLoading());

    try {
      await _repository.load();
    } catch (error, stackTrace) {
      // Anything that stops the load must end in a retry screen, not an endless spinner.
      addError(error, stackTrace);
      emit(const PaymentsLoadFailure());
      return;
    }
    // A newer PaymentsStarted may have replaced this handler while loading.
    if (emit.isDone) return;

    await emit.forEach(_repository.watch(), onData: PaymentsLoaded.new);
  }
}
