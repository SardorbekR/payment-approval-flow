import 'package:flutter_test/flutter_test.dart';
import 'package:payment_approval/features/payments/domain/models/money.dart';
import 'package:payment_approval/features/payments/domain/models/monthly_summary.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';

import '../../payments_seed.dart';

void main() {
  // Dates are built in local time and converted to UTC, the same way the app
  // stores them, so these tests pass in any machine time zone.
  final now = DateTime(2026, 9, 29, 12);

  MonthlySummary summarize(List<Payment> payments, {DateTime? at}) =>
      MonthlySummary.of(payments, now: at ?? now, currency: Currency.aed);

  group('MonthlySummary.of', () {
    test('totals the approved payments decided this month', () {
      final summary = summarize([
        tPayment(decidedAt: DateTime(2026, 9, 10).toUtc()),
        tPayment(id: 'pay_2', minorUnits: 34000, decidedAt: DateTime(2026, 9, 20).toUtc()),
      ]);

      expect(summary.total, const Money(154000, Currency.aed));
      expect(summary.approvedCount, 2);
      expect(summary.rejectedCount, 0);
    });

    test('leaves rejected payments out of the total and counts them separately', () {
      final summary = summarize([
        tPayment(decidedAt: DateTime(2026, 9, 10).toUtc()),
        tPayment(
          id: 'pay_2',
          minorUnits: 90000,
          status: PaymentStatus.rejected,
          decidedAt: DateTime(2026, 9, 12).toUtc(),
        ),
      ]);

      expect(summary.total, const Money(120000, Currency.aed));
      expect(summary.approvedCount, 1);
      expect(summary.rejectedCount, 1);
    });

    test('ignores payments decided in other months', () {
      final summary = summarize([
        tPayment(decidedAt: DateTime(2026, 8, 31, 23, 59).toUtc()),
        tPayment(id: 'pay_2', decidedAt: DateTime(2026, 10, 2).toUtc()),
        tPayment(
          id: 'pay_3',
          status: PaymentStatus.rejected,
          decidedAt: DateTime(2026, 8, 15).toUtc(),
        ),
      ]);

      expect(
        summary,
        const MonthlySummary(
          total: Money.zero(Currency.aed),
          approvedCount: 0,
          rejectedCount: 0,
        ),
      );
    });

    test('includes a payment decided exactly at the start of the month', () {
      final summary = summarize([tPayment(decidedAt: DateTime(2026, 9).toUtc())]);

      expect(summary.approvedCount, 1);
    });

    test('excludes a payment decided exactly at the start of next month', () {
      final summary = summarize([tPayment(decidedAt: DateTime(2026, 10).toUtc())]);

      expect(summary.approvedCount, 0);
    });

    test('rolls over from December into January of the next year', () {
      final december = DateTime(2026, 12, 15);

      final summary = summarize(
        [
          tPayment(decidedAt: DateTime(2026, 12, 31, 23, 59).toUtc()),
          tPayment(id: 'pay_2', decidedAt: DateTime(2027).toUtc()),
        ],
        at: december,
      );

      expect(summary.approvedCount, 1);
    });

    test('uses local month boundaries even when now is given in UTC', () {
      final payments = [
        tPayment(decidedAt: DateTime(2026, 9).toUtc()),
        tPayment(id: 'pay_2', decidedAt: DateTime(2026, 8, 31, 23, 59).toUtc()),
      ];

      expect(summarize(payments, at: now.toUtc()), summarize(payments));
    });
  });
}
