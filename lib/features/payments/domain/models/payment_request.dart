import 'package:equatable/equatable.dart';
import 'package:payment_approval/features/payments/domain/models/money.dart';

/// A payment waiting for the user's decision.
///
/// It deliberately carries no amount and no full recipient name. The server
/// sends only a masked name, and the full payment comes back from the decision
/// call, which the app makes after device authentication succeeds. A pending
/// request has nothing sensitive to leak.
class PaymentRequest extends Equatable {
  const PaymentRequest({
    required this.id,
    required this.reference,
    required this.maskedRecipient,
    required this.currency,
    required this.requestedAt,
  });

  /// Becomes the payment's id once the request is decided.
  final String id;
  final String reference;

  /// Recipient name as masked by the server, for example `A•••• K.`.
  final String maskedRecipient;
  final Currency currency;

  /// When the request came in, as a UTC instant.
  final DateTime requestedAt;

  @override
  List<Object?> get props => [id, reference, maskedRecipient, currency, requestedAt];
}
