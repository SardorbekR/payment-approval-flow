import 'package:intl/intl.dart';
import 'package:payment_approval/features/payments/domain/models/money.dart';

// Keeps the currency code and the amount on one line
const _nbsp = '\u00A0';

final _groupedWholeUnits = NumberFormat.decimalPattern('en');

String formatMoney(Money money) {
  final digits = money.currency.minorUnitDigits;
  var unitsPerWhole = 1;
  for (var i = 0; i < digits; i++) {
    unitsPerWhole *= 10;
  }

  final absolute = money.minorUnits.abs();
  final whole = _groupedWholeUnits.format(absolute ~/ unitsPerWhole);
  final fraction = digits == 0
      ? ''
      : '.${(absolute % unitsPerWhole).toString().padLeft(digits, '0')}';
  final sign = money.minorUnits < 0 ? '-' : '';

  return '${money.currency.code}$_nbsp$sign$whole$fraction';
}

/// Same shape for every amount, so it doesn't hint at the size
String maskedAmount(Currency currency) => '${currency.code}$_nbsp••,•••.••';
