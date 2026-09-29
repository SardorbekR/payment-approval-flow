import 'package:intl/intl.dart';
import 'package:payment_approval/features/payments/domain/models/money.dart';

// A non-breaking space keeps the currency code and the amount on one line.
const _nbsp = ' ';

final _groupedWholeUnits = NumberFormat.decimalPattern('en');

/// Formats money as "AED 1,200.00".
///
/// The whole and fractional parts are split with integer arithmetic, so the
/// amount never passes through a floating point number and can't be rounded.
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

/// The amount mask shown before device authentication. It has the same shape
/// for every amount, so it doesn't reveal how large the payment is.
String maskedAmount(Currency currency) => '${currency.code}$_nbsp••,•••.••';
