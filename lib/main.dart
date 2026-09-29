import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/app.dart';
import 'package:payment_approval/core/device_auth/local_device_authenticator.dart';
import 'package:payment_approval/core/device_auth/simulated_device_authenticator.dart';
import 'package:payment_approval/features/payments/data/data_sources/in_memory_payments_api.dart';
import 'package:payment_approval/features/payments/data/repositories/payments_repository.dart';

void main() {
  LicenseRegistry.addLicense(_fontLicenses);
  final navigatorKey = GlobalKey<NavigatorState>();

  runApp(
    App(
      navigatorKey: navigatorKey,
      repository: PaymentsRepository(
        api: InMemoryPaymentsApi(latency: const Duration(milliseconds: 400)),
      ),
      // Browsers have no access to Face ID or fingerprint sensors.
      authenticator: kIsWeb
          ? SimulatedDeviceAuthenticator(navigatorKey: navigatorKey)
          : LocalDeviceAuthenticator(),
    ),
  );
}

Stream<LicenseEntry> _fontLicenses() async* {
  final license = await rootBundle.loadString('assets/fonts/inter/OFL.txt');
  yield LicenseEntryWithLineBreaks(const ['Inter'], license);
}
