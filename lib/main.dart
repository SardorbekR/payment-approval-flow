import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/app.dart';
import 'package:payment_approval/core/device_auth/local_device_authenticator.dart';
import 'package:payment_approval/core/device_auth/simulated_device_authenticator.dart';
import 'package:payment_approval/features/payments/data/data_sources/in_memory_payments_data_source.dart';
import 'package:payment_approval/features/payments/domain/repositories/payments_repository.dart';

void main() {
  LicenseRegistry.addLicense(_fontLicenses);
  // Lets the approval sheet and the web's simulated prompt open from outside any page
  final navigatorKey = GlobalKey<NavigatorState>();

  runApp(
    App(
      navigatorKey: navigatorKey,
      repository: PaymentsRepository(
        dataSource: InMemoryPaymentsDataSource(latency: const Duration(milliseconds: 400)),
      ),
      // Browsers can't use Face ID or fingerprint
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
