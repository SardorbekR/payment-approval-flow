import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/core/device_auth/device_authenticator.dart';
import 'package:payment_approval/core/device_auth/simulated_device_authenticator.dart';
import 'package:payment_approval/l10n/app_localizations.dart';

import '../../helpers/test_app.dart';

void main() {
  late GlobalKey<NavigatorState> navigatorKey;
  late SimulatedDeviceAuthenticator authenticator;

  setUp(() {
    navigatorKey = GlobalKey<NavigatorState>();
    authenticator = SimulatedDeviceAuthenticator(navigatorKey: navigatorKey);
  });

  Future<void> pumpHost(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SizedBox(),
      ),
    );
  }

  group('authenticate', () {
    testWidgets('shows the reason and says that it is a simulation', (tester) async {
      await pumpHost(tester);

      authenticator.authenticate(reason: 'Confirm payment PAY-88213');
      await tester.pumpAndSettle();

      expect(find.text('Confirm payment PAY-88213'), findsOneWidget);
      expect(find.textContaining('Simulated device authentication'), findsOneWidget);
    });

    testWidgets('stacks its three choices at full width with even gaps on a phone', (
      tester,
    ) async {
      usePhoneScreen(tester);
      await pumpHost(tester);
      authenticator.authenticate(reason: 'Confirm payment PAY-88213');
      await tester.pumpAndSettle();

      final buttons = [
        for (final label in ['Authenticate', 'Fail', 'Cancel'])
          tester.getRect(
            find.ancestor(of: find.text(label), matching: find.bySubtype<ButtonStyleButton>()),
          ),
      ];
      expect({for (final button in buttons) button.width}, hasLength(1));
      expect(buttons[1].top - buttons[0].bottom, buttons[2].top - buttons[1].bottom);
    });

    final answers = {
      'Authenticate': DeviceAuthResult.success,
      'Cancel': DeviceAuthResult.canceled,
      'Fail': DeviceAuthResult.failed,
    };

    for (final MapEntry(key: button, value: expected) in answers.entries) {
      testWidgets('returns ${expected.name} when $button is chosen', (tester) async {
        await pumpHost(tester);
        final result = authenticator.authenticate(reason: 'Confirm payment PAY-88213');
        await tester.pumpAndSettle();

        await tester.tap(find.text(button));
        await tester.pumpAndSettle();

        expect(await result, expected);
      });
    }

    testWidgets('treats a prompt closed without an answer as canceled', (tester) async {
      await pumpHost(tester);
      final result = authenticator.authenticate(reason: 'Confirm payment PAY-88213');
      await tester.pumpAndSettle();

      navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();

      expect(await result, DeviceAuthResult.canceled);
    });

    testWidgets('reports unavailable before the app has a navigator', (tester) async {
      expect(
        await authenticator.authenticate(reason: 'Confirm payment PAY-88213'),
        DeviceAuthResult.unavailable,
      );
    });
  });
}
