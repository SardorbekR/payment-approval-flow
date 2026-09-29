import 'package:intl/intl.dart';
import 'package:payment_approval/l10n/app_localizations.dart';

/// Short form for lists: "Today, 2:32 PM", "Yesterday, 9:10 AM", "Sep 10, 2:32 PM",
/// or "Sep 10, 2025" for another year. Compares calendar days in local time,
/// so daylight saving changes can't shift "today".
String formatPaymentDate(
  DateTime instant, {
  required DateTime now,
  required AppLocalizations l10n,
}) {
  final local = instant.toLocal();
  final localNow = now.toLocal();
  final time = DateFormat.jm(l10n.localeName).format(local);

  if (_isSameDay(local, localNow)) return l10n.paymentDateToday(time);
  if (_isSameDay(local, DateTime(localNow.year, localNow.month, localNow.day - 1))) {
    return l10n.paymentDateYesterday(time);
  }
  if (local.year == localNow.year) {
    return l10n.dateAndTime(DateFormat.MMMd(l10n.localeName).format(local), time);
  }

  return DateFormat.yMMMd(l10n.localeName).format(local);
}

/// Full form for the details screen: "Sep 10, 2026, 2:32 PM".
String formatFullDate(DateTime instant, {required AppLocalizations l10n}) {
  final local = instant.toLocal();

  return l10n.dateAndTime(
    DateFormat.yMMMd(l10n.localeName).format(local),
    DateFormat.jm(l10n.localeName).format(local),
  );
}

/// Month and year for list sections: "September 2026".
String formatMonthYear(DateTime instant, {required AppLocalizations l10n}) =>
    DateFormat.yMMMM(l10n.localeName).format(instant.toLocal());

bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
