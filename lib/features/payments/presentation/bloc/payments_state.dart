part of 'payments_bloc.dart';

sealed class PaymentsState extends Equatable {
  const PaymentsState();

  @override
  List<Object?> get props => [];
}

final class PaymentsLoading extends PaymentsState {
  const PaymentsLoading();
}

final class PaymentsLoadFailure extends PaymentsState {
  const PaymentsLoadFailure();
}

final class PaymentsLoaded extends PaymentsState {
  const PaymentsLoaded(this.snapshot);

  final PaymentsSnapshot snapshot;

  @override
  List<Object?> get props => [snapshot];
}
