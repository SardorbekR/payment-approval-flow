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

Map<String, Object?> tPaymentJson({
  String id = 'pay_5e1d0a42',
  String status = 'approved',
  String decidedAt = '2026-09-10T11:32:00.000Z',
}) {
  return {
    'id': id,
    'reference': 'PAY-88213',
    'recipient_name': 'Ahmed Khalil',
    'amount': {'minor_units': 120000, 'currency': 'AED'},
    'status': status,
    'decided_at': decidedAt,
    'note': 'Design retainer',
  };
}

Map<String, Object?> tRequestJson({
  String id = 'pay_7f3a9c01',
  String requestedAt = '2026-09-29T08:15:00.000Z',
}) {
  return {
    'id': id,
    'reference': 'PAY-40117',
    'recipient_masked': 'A•••• K.',
    'currency': 'AED',
    'requested_at': requestedAt,
  };
}
