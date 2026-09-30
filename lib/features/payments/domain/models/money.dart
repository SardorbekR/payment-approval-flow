import 'package:equatable/equatable.dart';

/// Only AED for now. Another currency would need its own monthly total
enum Currency {
  aed('AED', 2);

  Currency(this.code, this.minorUnitDigits);

  final String code;
  final int minorUnitDigits;

  static Currency fromCode(String code) {
    for (final currency in values) {
      if (currency.code == code) return currency;
    }

    throw FormatException('Unsupported currency code', code);
  }
}

/// Integer minor units (120000 fils is AED 1,200.00), never a double
class Money extends Equatable {
  const Money(this.minorUnits, this.currency);

  const Money.zero(this.currency) : minorUnits = 0;

  final int minorUnits;
  final Currency currency;

  @override
  List<Object?> get props => [minorUnits, currency];
}
