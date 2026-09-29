import 'package:payment_approval/features/payments/domain/models/money.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';
import 'package:payment_approval/features/payments/domain/models/payment_request.dart';

Payment tPayment({
  String id = 'pay_1',
  String reference = 'PAY-10001',
  String recipientName = 'Ahmed Khalil',
  int minorUnits = 120000,
  PaymentStatus status = PaymentStatus.approved,
  DateTime? decidedAt,
  String? note,
}) {
  return Payment(
    id: id,
    reference: reference,
    recipientName: recipientName,
    amount: Money(minorUnits, Currency.aed),
    status: status,
    decidedAt: decidedAt ?? DateTime.utc(2026, 9, 10, 9, 30),
    note: note,
  );
}

PaymentRequest tRequest({
  String id = 'pay_req_1',
  String reference = 'PAY-20001',
  String maskedRecipient = 'S•••• M.',
  DateTime? requestedAt,
}) {
  return PaymentRequest(
    id: id,
    reference: reference,
    maskedRecipient: maskedRecipient,
    currency: Currency.aed,
    requestedAt: requestedAt ?? DateTime.utc(2026, 9, 29, 8),
  );
}
