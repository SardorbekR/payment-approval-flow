part of 'payments_bloc.dart';

sealed class PaymentsState extends Equatable {
  const PaymentsState();

  @override
  List<Object?> get props => [];
}

class PaymentsLoading extends PaymentsState {
  const PaymentsLoading();
}

class PaymentsError extends PaymentsState {
  const PaymentsError();
}

class PaymentsLoaded extends PaymentsState {
  const PaymentsLoaded(this.snapshot);

  final PaymentsSnapshot snapshot;

  @override
  List<Object?> get props => [snapshot];
}
