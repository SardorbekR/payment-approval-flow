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

    testWidgets('adds nothing on a narrow window', (tester) async {
      await pumpFrame(tester, enabled: true, window: const Size(430, 900));

      expect(find.text('Payment approval flow'), findsNothing);
      expect(appSize, const Size(430, 900));
    });

    testWidgets('adds nothing when turned off', (tester) async {
      await pumpFrame(tester, enabled: false, window: const Size(1440, 900));

      expect(find.text('Payment approval flow'), findsNothing);
    });
  });
}
