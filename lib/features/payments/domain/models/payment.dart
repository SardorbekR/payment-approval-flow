import 'package:equatable/equatable.dart';
import 'package:payment_approval/features/payments/domain/models/money.dart';

/// Always decided. A payment still waiting is a `PaymentRequest`
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
  final String reference;
  final String recipientName;
  final Money amount;
  final PaymentStatus status;
  final DateTime decidedAt;
  final String? note;

  @override
  List<Object?> get props => [id, reference, recipientName, amount, status, decidedAt, note];
}
