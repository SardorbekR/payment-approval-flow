import 'package:flutter_test/flutter_test.dart';
import 'package:payment_approval/features/payments/data/models/payment_json.dart';
import 'package:payment_approval/features/payments/domain/models/money.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';
import 'package:payment_approval/features/payments/domain/models/payment_request.dart';

const tPaymentJson = <String, Object?>{
  'id': 'pay_5e1d0a42',
  'reference': 'PAY-88213',
  'recipient_name': 'Ahmed Khalil',
  'amount': {'minor_units': 120000, 'currency': 'AED'},
  'status': 'approved',
  'decided_at': '2026-09-10T11:32:00.000Z',
  'note': 'Design retainer',
};

const tRequestJson = <String, Object?>{
  'id': 'pay_7f3a9c01',
  'reference': 'PAY-40117',
  'recipient_masked': 'A•••• K.',
  'currency': 'AED',
  'requested_at': '2026-09-29T08:15:00.000Z',
};

Matcher throwsFormatExceptionFor(String field) => throwsA(
  isA<FormatException>().having((error) => error.message, 'message', contains('"$field"')),
);

void main() {
  group('paymentFromJson', () {
    test('parses a decided payment', () {
      expect(
        paymentFromJson(tPaymentJson),
        Payment(
          id: 'pay_5e1d0a42',
          reference: 'PAY-88213',
          recipientName: 'Ahmed Khalil',
          amount: const Money(120000, Currency.aed),
          status: PaymentStatus.approved,
          decidedAt: DateTime.utc(2026, 9, 10, 11, 32),
          note: 'Design retainer',
        ),
      );
    });

    test('accepts a timestamp with an offset and keeps it as a UTC instant', () {
      final payment = paymentFromJson({...tPaymentJson, 'decided_at': '2026-09-10T15:32:00+04:00'});

      expect(payment.decidedAt, DateTime.utc(2026, 9, 10, 11, 32));
      expect(payment.decidedAt.isUtc, isTrue);
    });

    test('treats a missing or blank note as no note', () {
      expect(paymentFromJson({...tPaymentJson, 'note': null}).note, isNull);
      expect(paymentFromJson({...tPaymentJson, 'note': '  '}).note, isNull);
    });

    test('rejects a payment without an id', () {
      expect(
        () => paymentFromJson({...tPaymentJson}..remove('id')),
        throwsFormatExceptionFor('id'),
      );
    });

    test('rejects a blank recipient name', () {
      expect(
        () => paymentFromJson({...tPaymentJson, 'recipient_name': ' '}),
        throwsFormatExceptionFor('recipient_name'),
      );
    });

    test('rejects an amount with a fractional part', () {
      expect(
        () => paymentFromJson({
          ...tPaymentJson,
          'amount': {'minor_units': 1200.5, 'currency': 'AED'},
        }),
        throwsFormatExceptionFor('amount.minor_units'),
      );
    });

    test('rejects an amount sent as a string', () {
      expect(
        () => paymentFromJson({
          ...tPaymentJson,
          'amount': {'minor_units': '120000', 'currency': 'AED'},
        }),
        throwsFormatExceptionFor('amount.minor_units'),
      );
    });

    test('rejects a zero or negative amount', () {
      for (final minorUnits in [0, -500]) {
        expect(
          () => paymentFromJson({
            ...tPaymentJson,
            'amount': {'minor_units': minorUnits, 'currency': 'AED'},
          }),
          throwsFormatExceptionFor('amount.minor_units'),
        );
      }
    });

    test('rejects an unsupported currency', () {
      expect(
        () => paymentFromJson({
          ...tPaymentJson,
          'amount': {'minor_units': 120000, 'currency': 'USD'},
        }),
        throwsFormatExceptionFor('currency'),
      );
    });

    test('rejects a status other than approved or rejected', () {
      expect(
        () => paymentFromJson({...tPaymentJson, 'status': 'pending'}),
        throwsFormatExceptionFor('status'),
      );
    });

    test('rejects a timestamp without a time zone', () {
      expect(
        () => paymentFromJson({...tPaymentJson, 'decided_at': '2026-09-10T11:32:00'}),
        throwsFormatExceptionFor('decided_at'),
      );
    });

    test('rejects a timestamp it cannot parse', () {
      expect(
        () => paymentFromJson({...tPaymentJson, 'decided_at': 'yesterday'}),
        throwsFormatExceptionFor('decided_at'),
      );
    });
  });

  group('paymentRequestFromJson', () {
    test('parses a pending request', () {
      expect(
        paymentRequestFromJson(tRequestJson),
        PaymentRequest(
          id: 'pay_7f3a9c01',
          reference: 'PAY-40117',
          maskedRecipient: 'A•••• K.',
          currency: Currency.aed,
          requestedAt: DateTime.utc(2026, 9, 29, 8, 15),
        ),
      );
    });

    test('rejects a request without a masked recipient', () {
      expect(
        () => paymentRequestFromJson({...tRequestJson}..remove('recipient_masked')),
        throwsFormatExceptionFor('recipient_masked'),
      );
    });
  });

  group('paymentStatusToJson', () {
    test('uses the values the API expects', () {
      expect(paymentStatusToJson(PaymentStatus.approved), 'approved');
      expect(paymentStatusToJson(PaymentStatus.rejected), 'rejected');
    });
  });
}
