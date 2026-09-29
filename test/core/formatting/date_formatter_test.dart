import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/core/formatting/date_formatter.dart';
import 'package:payment_approval/l10n/app_localizations.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  // Inside the app, the Material localizations delegate loads this data
  setUpAll(() => initializeDateFormatting('en'));

  // Newer CLDR data puts a narrow no-break space before AM and PM
  String plain(String text) => text.replaceAll('\u202F', ' ');

  String relative(DateTime instant, DateTime now) =>
      plain(formatPaymentDate(instant.toUtc(), now: now, l10n: l10n));

  group('formatPaymentDate', () {
    final now = DateTime(2026, 9, 29, 12);

    test('says today for a payment decided today', () {
      expect(relative(DateTime(2026, 9, 29, 9, 5), now), 'Today, 9:05 AM');
    });

    test('says yesterday, also across a month boundary', () {
      expect(relative(DateTime(2026, 9, 28, 22), now), 'Yesterday, 10:00 PM');
      expect(relative(DateTime(2026, 9, 30, 22), DateTime(2026, 10, 1, 8)), 'Yesterday, 10:00 PM');
    });

    test('shows the day and time earlier in the year', () {
      expect(relative(DateTime(2026, 9, 10, 14, 32), now), 'Sep 10, 2:32 PM');
    });

    test('shows only the date for another year', () {
      expect(relative(DateTime(2025, 12, 31, 18), now), 'Dec 31, 2025');
    });
  });

  group('formatFullDate', () {
    test('shows the date and time in local time', () {
      final instant = DateTime(2026, 9, 10, 14, 32).toUtc();

      expect(plain(formatFullDate(instant, l10n: l10n)), 'Sep 10, 2026, 2:32 PM');
    });
  });

  group('formatMonthYear', () {
    test('names the month and year', () {
      expect(formatMonthYear(DateTime(2026, 9), l10n: l10n), 'September 2026');
    });
  });
}
