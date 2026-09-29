import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/app.dart';
import 'package:payment_approval/features/payments/data/data_sources/in_memory_payments_api.dart';
import 'package:payment_approval/features/payments/data/repositories/payments_repository.dart';

void main() {
  LicenseRegistry.addLicense(_fontLicenses);

  runApp(
    App(
      navigatorKey: GlobalKey<NavigatorState>(),
      repository: PaymentsRepository(
        api: InMemoryPaymentsApi(latency: const Duration(milliseconds: 400)),
      ),
    ),
  );
}

Stream<LicenseEntry> _fontLicenses() async* {
  final license = await rootBundle.loadString('assets/fonts/inter/OFL.txt');
  yield LicenseEntryWithLineBreaks(const ['Inter'], license);
}
