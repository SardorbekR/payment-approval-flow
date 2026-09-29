import 'package:equatable/equatable.dart';

/// Currencies the app supports (ISO 4217)
///
/// Accounts use only AED for now. Another currency would need separate monthly totals, since
/// amounts are never converted
enum Currency {
  aed('AED', 2);

  Currency(this.code, this.minorUnitDigits);

  final String code;

  /// Digits after the decimal point: 2 for AED, whose minor unit is the fils
  final int minorUnitDigits;

  /// Throws a [FormatException] for unsupported codes, so an unknown currency is never shown or
  /// summed as AED
  static Currency fromCode(String code) {
    for (final currency in values) {
      if (currency.code == code) return currency;
    }

    throw FormatException('Unsupported currency code', code);
  }
}

/// Exact amount of money in integer minor units (120000 fils is AED 1,200.00), never a double
class Money extends Equatable {
  const Money(this.minorUnits, this.currency);

  const Money.zero(this.currency) : minorUnits = 0;

  final int minorUnits;
  final Currency currency;

  @override
  List<Object?> get props => [minorUnits, currency];
}
