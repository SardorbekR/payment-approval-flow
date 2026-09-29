import 'package:equatable/equatable.dart';

/// ISO 4217 currencies the app understands.
///
/// Accounts are single-currency (AED) for now. Adding a currency means the
/// monthly summary needs per-currency totals, because amounts are never converted.
enum Currency {
  aed('AED', 2);

  Currency(this.code, this.minorUnitDigits);

  final String code;

  /// How many minor units make up the major unit's fraction: 2 for AED (fils).
  final int minorUnitDigits;

  /// Throws a [FormatException] for any code the app doesn't support, so an
  /// unexpected currency is never displayed or summed as if it were AED.
  static Currency fromCode(String code) {
    for (final currency in values) {
      if (currency.code == code) return currency;
    }

    throw FormatException('Unsupported currency code', code);
  }
}

/// An exact amount of money, stored as an integer number of minor units
/// (120000 fils is AED 1,200.00). Never a floating point number.
class Money extends Equatable {
  const Money(this.minorUnits, this.currency);

  const Money.zero(this.currency) : minorUnits = 0;

  final int minorUnits;
  final Currency currency;

  @override
  List<Object?> get props => [minorUnits, currency];
}
