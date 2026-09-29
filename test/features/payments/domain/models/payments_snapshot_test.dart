import 'package:flutter_test/flutter_test.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';
import 'package:payment_approval/features/payments/domain/models/payments_snapshot.dart';

import '../../payments_seed.dart';

void main() {
  final older = tPayment(id: 'pay_old', decidedAt: DateTime.utc(2026, 9));
  final newer = tPayment(id: 'pay_new', decidedAt: DateTime.utc(2026, 9, 20));
  final request = tRequest(id: 'pay_pending');

  group('PaymentsSnapshot', () {
    test('orders payments by most recent decision first', () {
      final snapshot = PaymentsSnapshot(payments: [older, newer], pendingRequests: const []);

      expect(snapshot.payments, [newer, older]);
    });

    test('breaks ties in decision time by id so the order is stable', () {
      final time = DateTime.utc(2026, 9, 5);
      final b = tPayment(id: 'pay_b', decidedAt: time);
      final a = tPayment(id: 'pay_a', decidedAt: time);

      final snapshot = PaymentsSnapshot(payments: [b, a], pendingRequests: const []);

      expect(snapshot.payments, [a, b]);
    });

    test('orders pending requests newest first', () {
      final first = tRequest(id: 'pay_r1', requestedAt: DateTime.utc(2026, 9, 29, 8));
      final second = tRequest(id: 'pay_r2', requestedAt: DateTime.utc(2026, 9, 29, 9));

      final snapshot = PaymentsSnapshot(payments: const [], pendingRequests: [first, second]);

      expect(snapshot.pendingRequests, [second, first]);
    });

    test('exposes lists that cannot be modified from outside', () {
      final snapshot = PaymentsSnapshot(payments: [older], pendingRequests: [request]);

      expect(() => snapshot.payments.add(newer), throwsUnsupportedError);
      expect(() => snapshot.pendingRequests.clear(), throwsUnsupportedError);
    });
  });

  group('paymentById', () {
    final snapshot = PaymentsSnapshot(payments: [older, newer], pendingRequests: [request]);

    test('returns the decided payment with that id', () {
      expect(snapshot.paymentById('pay_new'), newer);
    });

    test('returns null for a request that is still pending', () {
      expect(snapshot.paymentById('pay_pending'), isNull);
    });

    test('returns null for an unknown id', () {
      expect(snapshot.paymentById('pay_missing'), isNull);
    });
  });

  group('withPendingRequest', () {
    test('adds the request without touching payments', () {
      final snapshot = PaymentsSnapshot(payments: [older], pendingRequests: const []);

      final updated = snapshot.withPendingRequest(request);

      expect(updated.pendingRequests, [request]);
      expect(updated.payments, [older]);
    });

    test('replaces a request with the same id instead of duplicating it', () {
      final snapshot = PaymentsSnapshot(payments: const [], pendingRequests: [request]);

      final updated = snapshot.withPendingRequest(request);

      expect(updated.pendingRequests, [request]);
    });
  });

  group('withDecidedPayment', () {
    test('moves the request into the payments in a single step', () {
      final snapshot = PaymentsSnapshot(payments: [older], pendingRequests: [request]);
      final decided = tPayment(id: 'pay_pending', decidedAt: DateTime.utc(2026, 9, 29, 10));

      final updated = snapshot.withDecidedPayment(decided);

      expect(updated.pendingRequests, isEmpty);
      expect(updated.payments, [decided, older]);
    });

    test('puts a request that arrived earlier but was decided last on top', () {
      final snapshot = PaymentsSnapshot(payments: [newer], pendingRequests: const []);
      final decidedLate = tPayment(
        id: 'pay_dismissed_earlier',
        status: PaymentStatus.rejected,
        decidedAt: DateTime.utc(2026, 9, 29, 18),
      );

      final updated = snapshot.withDecidedPayment(decidedLate);

      expect(updated.payments.first, decidedLate);
    });
  });

  group('withoutPendingRequest', () {
    test('removes only the request with that id', () {
      final other = tRequest(id: 'pay_other');
      final snapshot = PaymentsSnapshot(payments: const [], pendingRequests: [request, other]);

      final updated = snapshot.withoutPendingRequest('pay_pending');

      expect(updated.pendingRequests, [other]);
    });
  });
}
