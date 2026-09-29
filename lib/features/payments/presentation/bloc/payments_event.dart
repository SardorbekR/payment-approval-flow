part of 'payments_bloc.dart';

sealed class PaymentsEvent {
  const PaymentsEvent();
}

/// Loads the payments and follows every change after that. Also used to retry.
final class PaymentsStarted extends PaymentsEvent {
  const PaymentsStarted();
}
