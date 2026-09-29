import 'package:flutter_test/flutter_test.dart';
import 'package:payment_approval/core/formatting/money_formatter.dart';
import 'package:payment_approval/features/payments/domain/models/money.dart';

void main() {
  group('formatMoney', () {
    test('shows the currency code and two decimals', () {
      expect(formatMoney(const Money(120000, Currency.aed)), 'AED 1,200.00');
    });

    test('keeps fils exact', () {
      expect(formatMoney(const Money(12550, Currency.aed)), 'AED 125.50');
      expect(formatMoney(const Money(1, Currency.aed)), 'AED 0.01');
      expect(formatMoney(const Money.zero(Currency.aed)), 'AED 0.00');
    });

    test('groups large amounts without rounding them', () {
      expect(formatMoney(const Money(999999999999, Currency.aed)), 'AED 9,999,999,999.99');
    });

    test('puts the sign after the currency code', () {
      expect(formatMoney(const Money(-12550, Currency.aed)), 'AED -125.50');
    });
  });

  group('maskedAmount', () {
    test('has the same shape for every amount, so it reveals nothing', () {
      expect(maskedAmount(Currency.aed), 'AED ••,•••.••');
    });
  });
}
