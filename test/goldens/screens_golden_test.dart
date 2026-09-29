@Tags(['golden'])
library;

import 'dart:io';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/app.dart';
import 'package:payment_approval/features/payments/data/data_sources/in_memory_payments_data_source.dart';
import 'package:payment_approval/features/payments/domain/repositories/payments_repository.dart';

import '../helpers/fakes.dart';

/// Whole-app screenshots, also used in the README. Text rendering differs
/// slightly between operating systems, so they are recorded and compared on
/// macOS only.
void main() {
  final now = DateTime(2026, 9, 29, 12);

  Future<void> pumpApp(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    Size window = const Size(390, 844),
    double pixelRatio = 3,
    bool framed = false,
  }) async {
    tester.view
      ..physicalSize = window * pixelRatio
      ..devicePixelRatio = pixelRatio
      ..padding = framed
          ? FakeViewPadding.zero
          : FakeViewPadding(top: 47 * pixelRatio, bottom: 34 * pixelRatio);
    tester.platformDispatcher.platformBrightnessTestValue = brightness;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(
      App(
        navigatorKey: GlobalKey<NavigatorState>(),
        repository: PaymentsRepository(dataSource: InMemoryPaymentsDataSource(random: Random(3))),
        authenticator: FakeDeviceAuthenticator(),
        showDemoFrame: framed,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openApprovalSheet(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
  }

  Future<void> matchesScreen(String name) =>
      expectLater(find.byType(App), matchesGoldenFile('goldens/$name.png'));

  final onMacOS = Platform.isMacOS;

  testWidgets('home, payments and details', (tester) async {
    await withClock(Clock.fixed(now), () async {
      await pumpApp(tester);
      await matchesScreen('home_light');

      await tester.tap(find.text('Payments').last);
      await tester.pumpAndSettle();
      await matchesScreen('payments_light');

      await tester.tap(find.text('Ahmed Khalil'));
      await tester.pumpAndSettle();
      await matchesScreen('details_light');
    });
  }, skip: !onMacOS);

  testWidgets('approval sheet', (tester) async {
    await withClock(Clock.fixed(now), () async {
      await pumpApp(tester);
      await openApprovalSheet(tester);
      await matchesScreen('approval_sheet_light');
    });
  }, skip: !onMacOS);

  testWidgets('dark mode', (tester) async {
    await withClock(Clock.fixed(now), () async {
      await pumpApp(tester, brightness: Brightness.dark);
      await matchesScreen('home_dark');

      await openApprovalSheet(tester);
      await matchesScreen('approval_sheet_dark');
    });
  }, skip: !onMacOS);

  testWidgets('web demo on a wide window', (tester) async {
    await withClock(Clock.fixed(now), () async {
      await pumpApp(tester, window: const Size(1440, 900), pixelRatio: 1.5, framed: true);
      await matchesScreen('web_demo_light');
    });
  }, skip: !onMacOS);
}
