import 'package:payment_approval/features/payments/domain/models/money.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';
import 'package:payment_approval/features/payments/domain/models/payment_request.dart';
import 'package:payment_approval/features/payments/domain/models/payments_snapshot.dart';

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

/// Mirrors the wireframe in September 2026, plus one payment from August.
final tWireframeSnapshot = PaymentsSnapshot(
  payments: [
    tPayment(
      id: 'pay_ahmed',
      reference: 'PAY-88213',
      decidedAt: DateTime(2026, 9, 26, 10).toUtc(),
      note: 'Design retainer',
    ),
    tPayment(
      id: 'pay_sara',
      reference: 'PAY-51027',
      recipientName: 'Sara Mansour',
      minorUnits: 34000,
      decidedAt: DateTime(2026, 9, 18, 13).toUtc(),
    ),
    tPayment(
      id: 'pay_leo',
      reference: 'PAY-47390',
      recipientName: 'Leo Dubois',
      minorUnits: 90000,
      status: PaymentStatus.rejected,
      decidedAt: DateTime(2026, 9, 9, 16).toUtc(),
    ),
    tPayment(
      id: 'pay_fatima',
      reference: 'PAY-30958',
      recipientName: 'Fatima Al Zahra',
      minorUnits: 475000,
      decidedAt: DateTime(2026, 8, 28, 10).toUtc(),
    ),
  ],
  pendingRequests: const [],
);

/// "Now" for UI tests, so relative dates and the monthly summary are stable.
final tNow = DateTime(2026, 9, 29, 12);
