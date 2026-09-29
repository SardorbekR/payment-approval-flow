import 'dart:math';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/app.dart';
import 'package:payment_approval/core/device_auth/device_authenticator.dart';
import 'package:payment_approval/core/formatting/money_formatter.dart';
import 'package:payment_approval/features/approval/presentation/widgets/approval_sheet.dart';
import 'package:payment_approval/features/home/presentation/pages/home_page.dart';
import 'package:payment_approval/features/payments/data/data_sources/in_memory_payments_api.dart';
import 'package:payment_approval/features/payments/data/repositories/payments_repository.dart';
import 'package:payment_approval/features/payments/domain/models/money.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';
import 'package:payment_approval/features/payments/presentation/widgets/payment_tile.dart';

import 'helpers/fakes.dart';
import 'helpers/test_app.dart';

/// The whole app, end to end: real router, repository, in-memory server and
/// presenter. Only device authentication is faked.
void main() {
  final now = DateTime(2026, 9, 29, 12);
  late InMemoryPaymentsApi api;
  late FakeDeviceAuthenticator authenticator;

  Future<void> pumpApp(WidgetTester tester, {Size screen = const Size(390, 844)}) async {
    tester.view
      ..physicalSize = screen
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    api = InMemoryPaymentsApi(random: Random(7));
    authenticator = FakeDeviceAuthenticator();

    await tester.pumpWidget(
      App(
        navigatorKey: GlobalKey<NavigatorState>(),
        repository: PaymentsRepository(api: api),
        authenticator: authenticator,
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder debugButton() => find.byIcon(Icons.add_rounded);

  Future<String> receiveRequest(WidgetTester tester) async {
    await tester.tap(debugButton());
    await tester.pumpAndSettle();

    return tester
        .widget<Text>(
          find.descendant(
            of: find.byType(ApprovalSheet),
            matching: find.textContaining(RegExp(r'^PAY-\d{5}$')),
          ),
        )
        .data!;
  }

  Future<void> decide(WidgetTester tester, String button) async {
    await tester.tap(find.text(button));
    await tester.pumpAndSettle();
  }

  List<PaymentTile> visibleTiles(WidgetTester tester) =>
      tester.widgetList<PaymentTile>(find.byType(PaymentTile)).toList();

  int selectedTab(WidgetTester tester) =>
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;

  List<String> textsIn(WidgetTester tester, Finder area) => tester
      .widgetList<Text>(find.descendant(of: area, matching: find.byType(Text)))
      .map((text) => text.data ?? '')
      .toList();

  testWidgets('approving opens Payments with the payment on top and updates every screen', (
    tester,
  ) async {
    await withClock(Clock.fixed(now), () async {
      await pumpApp(tester);
      expect(find.text(aed('1,540.00')), findsOneWidget);

      final reference = await receiveRequest(tester);
      final shownBeforeApproval = textsIn(tester, find.byType(ApprovalSheet));
      await decide(tester, 'Approve');

      expect(authenticator.reasons.single, "Confirm it's you to approve payment $reference");
      expect(find.byType(ApprovalSheet), findsNothing);
      expect(selectedTab(tester), 1);
      final top = visibleTiles(tester).first;
      expect(top.payment.reference, reference);
      expect(top.payment.status, PaymentStatus.approved);
      expect(top.highlighted, isTrue);
      expect(find.text('Payment $reference approved'), findsOneWidget);

      // The sheet never showed who was paid or how much.
      expect(shownBeforeApproval, isNot(contains(top.payment.recipientName)));
      expect(shownBeforeApproval, isNot(contains(formatMoney(top.payment.amount))));

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      final newTotal = Money(154000 + top.payment.amount.minorUnits, Currency.aed);
      expect(find.text(formatMoney(newTotal)), findsOneWidget);
      expect(find.text('3 approved payments'), findsOneWidget);

      await tester.tap(find.text(top.payment.recipientName).first);
      await tester.pumpAndSettle();
      expect(find.text('Payment details'), findsOneWidget);
      expect(find.text(reference), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);
    });
  });

  testWidgets('approving over the details screen closes it and opens Payments', (tester) async {
    await withClock(Clock.fixed(now), () async {
      await pumpApp(tester);
      await tester.tap(find.text('Ahmed Khalil'));
      await tester.pumpAndSettle();
      expect(debugButton().hitTestable(), findsOneWidget);

      await receiveRequest(tester);
      await decide(tester, 'Approve');

      expect(find.text('Payment details'), findsNothing);
      expect(selectedTab(tester), 1);
    });
  });

  testWidgets('rejecting keeps the user where they were and moves no money', (tester) async {
    await withClock(Clock.fixed(now), () async {
      await pumpApp(tester);
      await tester.tap(find.text('Ahmed Khalil'));
      await tester.pumpAndSettle();

      final reference = await receiveRequest(tester);
      await decide(tester, 'Reject');

      expect(find.byType(ApprovalSheet), findsNothing);
      expect(find.text('Payment details'), findsOneWidget);
      expect(find.text('PAY-88213'), findsOneWidget);
      expect(find.text('Payment $reference rejected'), findsOneWidget);

      await tester.tap(find.text('View'));
      await tester.pumpAndSettle();
      expect(find.text(reference), findsOneWidget);
      expect(find.text('Rejected, so no money moved.'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text(aed('1,540.00')), findsOneWidget);
      expect(find.text('Excludes 2 rejected payments'), findsOneWidget);
      expect(visibleTiles(tester).first.payment.reference, reference);
    });
  });

  testWidgets('closing the sheet keeps the request waiting on Home, never in details', (
    tester,
  ) async {
    await withClock(Clock.fixed(now), () async {
      await pumpApp(tester);
      final reference = await receiveRequest(tester);

      await tester.tap(find.byTooltip('Decide later'));
      await tester.pumpAndSettle();

      expect(find.byType(ApprovalSheet), findsNothing);
      expect(find.text('Payment $reference is still waiting for your approval'), findsOneWidget);
      expect(find.text('WAITING FOR YOUR APPROVAL'), findsOneWidget);
      expect(find.text('Ref $reference'), findsOneWidget);
      expect(find.text(aed('1,540.00')), findsOneWidget);

      final pendingId = (await tester.runAsync(api.fetchPendingRequests))!.single['id']! as String;
      GoRouter.of(tester.element(find.byType(HomePage))).go('/payment/$pendingId');
      await tester.pumpAndSettle();
      expect(find.text('Payment unavailable'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ref $reference'));
      await tester.pumpAndSettle();
      expect(find.byType(ApprovalSheet), findsOneWidget);
      expect(find.text(reference), findsWidgets);

      await decide(tester, 'Approve');
      expect(find.text('Ref $reference'), findsNothing);
    });
  });

  testWidgets('the sheet cannot be closed while the device prompt is open', (tester) async {
    await withClock(Clock.fixed(now), () async {
      await pumpApp(tester);
      await receiveRequest(tester);
      authenticator.holdNextPrompt();

      await tester.tap(find.text('Approve'));
      await tester.pump();
      await tester.binding.handlePopRoute();
      await tester.tapAt(const Offset(20, 40));
      // The button spinner keeps animating while the prompt is open, so pump for a while
      // instead of waiting for the app to settle.
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ApprovalSheet), findsOneWidget);
      expect(find.text('Waiting for device authentication…'), findsOneWidget);

      authenticator.answerHeldPrompt(DeviceAuthResult.success);
      await tester.pumpAndSettle();
      expect(find.byType(ApprovalSheet), findsNothing);
      expect(selectedTab(tester), 1);
    });
  });

  testWidgets('a cancelled device prompt decides nothing', (tester) async {
    await withClock(Clock.fixed(now), () async {
      await pumpApp(tester);
      await receiveRequest(tester);
      authenticator.answer = DeviceAuthResult.cancelled;

      await decide(tester, 'Approve');

      expect(find.byType(ApprovalSheet), findsOneWidget);
      expect(await tester.runAsync(api.fetchPendingRequests), hasLength(1));
    });
  });

  testWidgets('a request decided elsewhere is reported and dropped', (tester) async {
    await withClock(Clock.fixed(now), () async {
      await pumpApp(tester);
      final reference = await receiveRequest(tester);
      await tester.tap(find.byTooltip('Decide later'));
      await tester.pumpAndSettle();

      final pendingId = (await tester.runAsync(api.fetchPendingRequests))!.single['id']! as String;
      await tester.runAsync(
        () => api.submitDecision(requestId: pendingId, decision: 'approved'),
      );
      await tester.tap(find.text('Ref $reference'));
      await tester.pumpAndSettle();
      await decide(tester, 'Approve');

      expect(find.textContaining('no longer available'), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(ApprovalSheet), findsNothing);
      expect(find.text('Ref $reference'), findsNothing);
      expect(find.textContaining('still waiting'), findsNothing);
    });
  });

  testWidgets('the debug button stays where it was dragged, across tabs and screens', (
    tester,
  ) async {
    await withClock(Clock.fixed(now), () async {
      await pumpApp(tester);
      await tester.drag(debugButton(), const Offset(-200, -400));
      await tester.pumpAndSettle();
      final position = tester.getCenter(debugButton());

      await tester.tap(find.text('Payments'));
      await tester.pumpAndSettle();
      expect(tester.getCenter(debugButton()), position);

      await tester.tap(find.byType(PaymentTile).first);
      await tester.pumpAndSettle();
      expect(tester.getCenter(debugButton()), position);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(tester.getCenter(debugButton()), position);
    });
  });

  testWidgets('everything fits at twice the text size', (tester) async {
    await withClock(Clock.fixed(now), () async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpApp(tester);
      await receiveRequest(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Approve'), findsOneWidget);
    });
  });

  testWidgets('everything fits in landscape', (tester) async {
    await withClock(Clock.fixed(now), () async {
      await pumpApp(tester, screen: const Size(844, 390));
      await receiveRequest(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Approve'), findsOneWidget);
    });
  });
}
