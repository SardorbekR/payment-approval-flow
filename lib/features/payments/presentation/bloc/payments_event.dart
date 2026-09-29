part of 'payments_bloc.dart';

sealed class PaymentsEvent {
  const PaymentsEvent();
}

/// Loads the payments and follows every change after that. Also used to retry
class LoadPayments extends PaymentsEvent {
  const LoadPayments();
}
