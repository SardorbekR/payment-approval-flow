import 'package:flutter_test/flutter_test.dart';
import 'package:payment_approval/features/payments/domain/models/money.dart';

void main() {
  group('Currency.fromCode', () {
    test('returns the currency for a supported code', () {
      expect(Currency.fromCode('AED'), Currency.aed);
    });

    test('throws a FormatException for an unsupported code', () {
      expect(() => Currency.fromCode('USD'), throwsFormatException);
    });

    test('is case sensitive, because ISO 4217 codes are upper case', () {
      expect(() => Currency.fromCode('aed'), throwsFormatException);
    });
  });

  group('Money', () {
    test('compares by value', () {
      expect(const Money(120000, Currency.aed), const Money(120000, Currency.aed));
      expect(const Money(120000, Currency.aed), isNot(const Money(120001, Currency.aed)));
    });

    test('zero has no minor units', () {
      expect(const Money.zero(Currency.aed), const Money(0, Currency.aed));
    });
  });
}
