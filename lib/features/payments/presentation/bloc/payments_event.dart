part of 'payments_bloc.dart';

sealed class PaymentsEvent {
  const PaymentsEvent();
}

class LoadPayments extends PaymentsEvent {
  const LoadPayments();
}
