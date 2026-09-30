import 'package:equatable/equatable.dart';
import 'package:payment_approval/features/payments/domain/models/money.dart';

/// Has no amount and no full name until the user authenticates
class PaymentRequest extends Equatable {
  const PaymentRequest({
    required this.id,
    required this.reference,
    required this.maskedRecipient,
    required this.currency,
    required this.requestedAt,
  });

  final String id;
  final String reference;
  final String maskedRecipient;
  final Currency currency;
  final DateTime requestedAt;

  @override
  List<Object?> get props => [id, reference, maskedRecipient, currency, requestedAt];
}
