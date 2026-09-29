import 'package:equatable/equatable.dart';
import 'package:payment_approval/features/payments/domain/models/money.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';

/// Money that actually moved during the current calendar month.
///
/// Only approved payments count toward [total] and [approvedCount]. Rejected
/// payments never moved money, so they are only counted in [rejectedCount].
class MonthlySummary extends Equatable {
  const MonthlySummary({
    required this.total,
    required this.approvedCount,
    required this.rejectedCount,
  });

  /// The month follows the user's local calendar, while each payment's
  /// `decidedAt` is an absolute instant, so comparisons work in any time zone.
  factory MonthlySummary.of(
    Iterable<Payment> payments, {
    required DateTime now,
    required Currency currency,
  }) {
    final localNow = now.toLocal();
    final monthStart = DateTime(localNow.year, localNow.month);
    final nextMonthStart = DateTime(localNow.year, localNow.month + 1);

    var totalMinorUnits = 0;
    var approvedCount = 0;
    var rejectedCount = 0;

    for (final payment in payments) {
      final decidedAt = payment.decidedAt;
      if (decidedAt.isBefore(monthStart) || !decidedAt.isBefore(nextMonthStart)) continue;

      switch (payment.status) {
        case PaymentStatus.approved:
          // Amounts are never converted between currencies.
          if (payment.amount.currency != currency) {
            throw ArgumentError.value(payment.amount, 'payments', 'Expected ${currency.code} only');
          }
          totalMinorUnits += payment.amount.minorUnits;
          approvedCount++;
        case PaymentStatus.rejected:
          rejectedCount++;
      }
    }

    return MonthlySummary(
      total: Money(totalMinorUnits, currency),
      approvedCount: approvedCount,
      rejectedCount: rejectedCount,
    );
  }

  final Money total;
  final int approvedCount;
  final int rejectedCount;

  @override
  List<Object?> get props => [total, approvedCount, rejectedCount];
}
