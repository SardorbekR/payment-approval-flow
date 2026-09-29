import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/features/shared/widgets/demo_frame.dart';

import '../../../helpers/test_app.dart';

void main() {
  Size? appSize;

  Widget app() => Builder(
    builder: (context) {
      appSize = MediaQuery.sizeOf(context);
      return const Text('The app');
    },
  );

  Future<void> pumpFrame(WidgetTester tester, {required bool enabled, required Size window}) async {
    tester.view
      ..physicalSize = window
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      testApp(
        child: DemoFrame(enabled: enabled, child: app()),
      ),
    );
  }

  group('DemoFrame', () {
    testWidgets('frames the app at phone size next to a guide on wide windows', (tester) async {
      await pumpFrame(tester, enabled: true, window: const Size(1440, 900));

      expect(find.text('Payment approval flow'), findsOneWidget);
      expect(appSize, const Size(390, 844));
    });

    testWidgets('adds nothing on windows too small to frame the app', (tester) async {
      for (final window in const [Size(430, 900), Size(768, 1024), Size(932, 430)]) {
        await pumpFrame(tester, enabled: true, window: window);

        expect(find.text('Payment approval flow'), findsNothing, reason: '$window');
        expect(appSize, window, reason: '$window');
      }
    });

    testWidgets('fits the phone into the smallest framed window without overflowing', (
      tester,
    ) async {
      await pumpFrame(tester, enabled: true, window: const Size(900, 640));

      expect(tester.takeException(), isNull);
      expect(appSize, const Size(390, 844));
      expect(tester.getRect(find.byType(FittedBox)).bottom, lessThanOrEqualTo(640));
    });

    testWidgets('never scales the phone up on a large window', (tester) async {
      await pumpFrame(tester, enabled: true, window: const Size(2560, 1440));

      final phone = tester.getSize(find.byType(FittedBox));
      expect(phone.width, lessThanOrEqualTo(390 + 2 * 12));
      expect(phone.height, lessThanOrEqualTo(844 + 2 * 12));
    });

    testWidgets('adds nothing when turned off', (tester) async {
      await pumpFrame(tester, enabled: false, window: const Size(1440, 900));

      expect(find.text('Payment approval flow'), findsNothing);
    });
  });
}
