import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';
import 'package:payment_approval/features/payments/domain/models/payments_snapshot.dart';
import 'package:payment_approval/features/payments/presentation/bloc/payments_bloc.dart';
import 'package:payment_approval/features/payments/presentation/pages/payments_page.dart';
import 'package:payment_approval/features/payments/presentation/widgets/payment_tile.dart';

import '../../../../helpers/test_app.dart';
import '../../payments_seed.dart';

void main() {
  late MockPaymentsBloc bloc;
  late StreamController<PaymentsState> states;

  setUp(() {
    bloc = MockPaymentsBloc();
    states = StreamController<PaymentsState>();
  });

  tearDown(() => states.close());

  Future<void> pumpPayments(WidgetTester tester, PaymentsSnapshot snapshot) async {
    whenListen(bloc, states.stream, initialState: PaymentsLoaded(snapshot));
    await tester.pumpWidget(testApp(child: const PaymentsPage(), paymentsBloc: bloc));
  }

  List<String> visibleNames(WidgetTester tester) => tester
      .widgetList<PaymentTile>(find.byType(PaymentTile, skipOffstage: false))
      .map((tile) => tile.payment.recipientName)
      .toList();

  group('PaymentsPage', () {
    testWidgets('lists every payment, most recent first, grouped by month', (tester) async {
      await withClock(Clock.fixed(tNow), () async {
        await pumpPayments(tester, tWireframeSnapshot);

        expect(visibleNames(tester), [
          'Ahmed Khalil',
          'Sara Mansour',
          'Leo Dubois',
          'Fatima Al Zahra',
        ]);
        expect(find.text('SEPTEMBER 2026'), findsOneWidget);
        expect(find.text('AUGUST 2026'), findsOneWidget);
      });
    });

    testWidgets('shows who, how much and the status in every row', (tester) async {
      await withClock(Clock.fixed(tNow), () async {
        await pumpPayments(tester, tWireframeSnapshot);

        final leo = find.ancestor(of: find.text('Leo Dubois'), matching: find.byType(PaymentTile));
        expect(find.descendant(of: leo, matching: find.text(aed('900.00'))), findsOneWidget);
        expect(find.descendant(of: leo, matching: find.text('Rejected')), findsOneWidget);
      });
    });

    testWidgets('keeps the amount beside the name at the default text size', (tester) async {
      await withClock(Clock.fixed(tNow), () async {
        usePhoneScreen(tester);
        await pumpPayments(tester, tWireframeSnapshot);

        final name = tester.getRect(find.text('Ahmed Khalil'));
        final amount = tester.getRect(find.text(aed('1,200.00')));
        expect(amount.top, lessThan(name.bottom));
        expect(amount.left, greaterThan(name.right));
      });
    });

    testWidgets('moves the amount under the name when the text is large', (tester) async {
      await withClock(Clock.fixed(tNow), () async {
        usePhoneScreen(tester, textScale: 2);
        await pumpPayments(tester, tWireframeSnapshot);

        final name = tester.getRect(find.text('Ahmed Khalil'));
        final amount = tester.getRect(find.text(aed('1,200.00')));
        expect(amount.top, greaterThan(name.bottom));
        expect(amount.left, name.left);
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('scrolls to and highlights a payment that was just decided', (tester) async {
      await withClock(Clock.fixed(tNow), () async {
        final history = PaymentsSnapshot(
          payments: [
            for (var day = 1; day <= 20; day++)
              tPayment(id: 'pay_$day', decidedAt: DateTime(2026, 9, day).toUtc()),
          ],
          pendingRequests: const [],
        );
        await pumpPayments(tester, history);
        await tester.drag(find.byType(ListView), const Offset(0, -600));
        await tester.pumpAndSettle();
        final position = tester.state<ScrollableState>(find.byType(Scrollable)).position;
        expect(position.pixels, greaterThan(0));

        states.add(
          PaymentsLoaded(
            history.withDecidedPayment(
              tPayment(
                id: 'pay_new',
                recipientName: 'Omar Haddad',
                decidedAt: DateTime(2026, 9, 29, 11).toUtc(),
              ),
            ),
          ),
        );
        // Let the listener run, then the scroll animation start and finish
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pump(const Duration(milliseconds: 400));

        PaymentTile newTile() => tester.widget<PaymentTile>(find.byKey(const ValueKey('pay_new')));
        expect(position.pixels, 0);
        expect(newTile().highlighted, isTrue);

        // Once the tint has faded the highlight is forgotten, so scrolling the row away and back
        // doesn't replay it
        await tester.pump(PaymentTile.highlightDuration);
        expect(newTile().highlighted, isFalse);
      });
    });

    testWidgets('does not highlight anything on the first load', (tester) async {
      await withClock(Clock.fixed(tNow), () async {
        await pumpPayments(tester, tWireframeSnapshot);

        final tiles = tester.widgetList<PaymentTile>(find.byType(PaymentTile));
        expect(tiles.where((tile) => tile.highlighted), isEmpty);
      });
    });

    testWidgets('shows an empty state without payments', (tester) async {
      await pumpPayments(tester, PaymentsSnapshot(payments: const [], pendingRequests: const []));

      expect(find.text('No payments yet'), findsOneWidget);
    });

    testWidgets('keeps rejected amounts but mutes them', (tester) async {
      await withClock(Clock.fixed(tNow), () async {
        await pumpPayments(
          tester,
          PaymentsSnapshot(
            payments: [tPayment(status: PaymentStatus.rejected)],
            pendingRequests: const [],
          ),
        );

        final amount = tester.widget<Text>(find.text(aed('1,200.00')));
        final theme = Theme.of(tester.element(find.byType(PaymentsPage)));
        expect(amount.style?.color, theme.colorScheme.onSurfaceVariant);
      });
    });
  });
}
