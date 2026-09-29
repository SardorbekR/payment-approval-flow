import 'package:equatable/equatable.dart';
import 'package:payment_approval/features/payments/domain/models/money.dart';

/// A payment only exists once it has been decided. A payment that is still
/// waiting for approval is a `PaymentRequest`, so it can never reach the list,
/// the summary or the details screen by accident.
enum PaymentStatus { approved, rejected }

class Payment extends Equatable {
  const Payment({
    required this.id,
    required this.reference,
    required this.recipientName,
    required this.amount,
    required this.status,
    required this.decidedAt,
    this.note,
  });

  final String id;

  /// Human-readable reference, for example `PAY-88213`.
  final String reference;
  final String recipientName;
  final Money amount;
  final PaymentStatus status;

  /// When the payment was approved or rejected, as a UTC instant.
  final DateTime decidedAt;
  final String? note;

  @override
  List<Object?> get props => [id, reference, recipientName, amount, status, decidedAt, note];
}
