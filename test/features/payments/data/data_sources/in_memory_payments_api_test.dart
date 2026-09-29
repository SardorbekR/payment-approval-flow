import 'dart:math';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payment_approval/features/payments/data/data_sources/in_memory_payments_api.dart';
import 'package:payment_approval/features/payments/data/data_sources/payments_api.dart';
import 'package:payment_approval/features/payments/data/data_sources/recipient_mask.dart';
import 'package:payment_approval/features/payments/data/models/payment_json.dart';
import 'package:payment_approval/features/payments/domain/models/money.dart';
import 'package:payment_approval/features/payments/domain/models/monthly_summary.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';

void main() {
  group('seed history', () {
    test('matches the wireframe: two approved and one rejected payment this month', () async {
      final now = DateTime(2026, 9, 29, 12);

      await withClock(Clock.fixed(now), () async {
        final payments = (await InMemoryPaymentsApi().fetchPayments()).map(paymentFromJson);

        expect(
          MonthlySummary.of(payments, now: now, currency: Currency.aed),
          const MonthlySummary(
            total: Money(154000, Currency.aed),
            approvedCount: 2,
            rejectedCount: 1,
          ),
        );
      });
    });

    test('stays in the current month minutes after midnight on the 1st', () async {
      final firstOfMonth = DateTime(2026, 10, 1, 0, 5);

      await withClock(Clock.fixed(firstOfMonth), () async {
        final payments = (await InMemoryPaymentsApi().fetchPayments()).map(paymentFromJson);
        final thisMonth = payments.where((payment) {
          return !payment.decidedAt.isBefore(DateTime(2026, 10)) &&
              !payment.decidedAt.isAfter(firstOfMonth);
        });

        expect(thisMonth, hasLength(3));
      });
    });

    test('has no pending requests', () async {
      expect(await InMemoryPaymentsApi().fetchPendingRequests(), isEmpty);
    });
  });

  group('createDebugRequest', () {
    test('sends a masked recipient and no amount', () async {
      final json = await InMemoryPaymentsApi(random: Random(1)).createDebugRequest();

      expect(
        json.keys,
        unorderedEquals(['id', 'reference', 'recipient_masked', 'currency', 'requested_at']),
      );
      expect(json['recipient_masked'], matches(RegExp(r'^\S•••• \S\.$')));
      expect(() => paymentRequestFromJson(json), returnsNormally);
    });

    test('keeps the request pending until it is decided', () async {
      final api = InMemoryPaymentsApi(random: Random(1));

      final json = await api.createDebugRequest();

      expect(await api.fetchPendingRequests(), [json]);
    });

    test('never reuses an id or a reference', () async {
      final api = InMemoryPaymentsApi(random: Random(7));

      final requests = [for (var i = 0; i < 300; i++) await api.createDebugRequest()];

      expect(requests.map((json) => json['id']).toSet(), hasLength(300));
      expect(requests.map((json) => json['reference']).toSet(), hasLength(300));
    });
  });

  group('submitDecision', () {
    test('returns the full payment and moves it out of the pending requests', () async {
      final api = InMemoryPaymentsApi(random: Random(1));
      final request = paymentRequestFromJson(await api.createDebugRequest());

      final payment = paymentFromJson(
        await api.submitDecision(requestId: request.id, decision: 'approved'),
      );

      expect(payment.id, request.id);
      expect(payment.reference, request.reference);
      expect(payment.status, PaymentStatus.approved);
      expect(maskRecipientName(payment.recipientName), request.maskedRecipient);
      expect(await api.fetchPendingRequests(), isEmpty);
      expect((await api.fetchPayments()).map(paymentFromJson), contains(payment));
    });

    test('stamps the decision with the current time', () async {
      final decisionTime = DateTime.utc(2026, 9, 29, 10, 42);

      await withClock(Clock.fixed(decisionTime), () async {
        final api = InMemoryPaymentsApi(random: Random(1));
        final request = paymentRequestFromJson(await api.createDebugRequest());

        final payment = paymentFromJson(
          await api.submitDecision(requestId: request.id, decision: 'rejected'),
        );

        expect(payment.decidedAt, decisionTime);
        expect(payment.status, PaymentStatus.rejected);
      });
    });

    test('refuses a request it does not know', () async {
      await expectLater(
        InMemoryPaymentsApi().submitDecision(requestId: 'pay_missing', decision: 'approved'),
        throwsA(isA<RequestUnavailableException>()),
      );
    });

    test('refuses to decide the same request twice', () async {
      final api = InMemoryPaymentsApi(random: Random(1));
      final request = paymentRequestFromJson(await api.createDebugRequest());
      await api.submitDecision(requestId: request.id, decision: 'approved');

      await expectLater(
        api.submitDecision(requestId: request.id, decision: 'rejected'),
        throwsA(isA<RequestUnavailableException>()),
      );
    });
  });
}
