import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:payment_approval/features/home/presentation/pages/home_page.dart';
import 'package:payment_approval/features/payments/domain/models/payments_snapshot.dart';
import 'package:payment_approval/features/payments/presentation/bloc/payments_bloc.dart';
import 'package:payment_approval/features/payments/presentation/widgets/payment_tile.dart';

import '../../../../helpers/test_app.dart';
import '../../../payments/payments_seed.dart';

void main() {
  late MockPaymentsBloc bloc;
  late MockApprovalPresenter presenter;

  setUpAll(() => registerFallbackValue(tRequest()));

  setUp(() {
    bloc = MockPaymentsBloc();
    presenter = MockApprovalPresenter();
    when(() => presenter.review(any())).thenAnswer((_) async {});
  });

  Future<void> pumpHome(
    WidgetTester tester,
    PaymentsState state, {
    TextDirection textDirection = TextDirection.ltr,
  }) async {
    whenListen(bloc, const Stream<PaymentsState>.empty(), initialState: state);
    await tester.pumpWidget(
      testApp(
        child: const HomePage(),
        paymentsBloc: bloc,
        presenter: presenter,
        textDirection: textDirection,
      ),
    );
  }

  group('HomePage', () {
    testWidgets('shows a spinner while payments load', (tester) async {
      await pumpHome(tester, const PaymentsLoading());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('sums only the money approved this month', (tester) async {
      await withClock(Clock.fixed(tNow), () async {
        await pumpHome(tester, PaymentsLoaded(tWireframeSnapshot));

        expect(find.text(aed('1,540.00')), findsOneWidget);
        expect(find.text('2 approved payments'), findsOneWidget);
        expect(find.text('Excludes 1 rejected payment'), findsOneWidget);
      });
    });

    testWidgets('lists the three most recent payments', (tester) async {
      await withClock(Clock.fixed(tNow), () async {
        await pumpHome(tester, PaymentsLoaded(tWireframeSnapshot));

        final names = tester
            .widgetList<PaymentTile>(find.byType(PaymentTile))
            .map((tile) => tile.payment.recipientName);
        expect(names, ['Ahmed Khalil', 'Sara Mansour', 'Leo Dubois']);
      });
    });

    testWidgets('invites the user to simulate a request when there are no payments', (
      tester,
    ) async {
      await withClock(Clock.fixed(tNow), () async {
        await pumpHome(
          tester,
          PaymentsLoaded(PaymentsSnapshot(payments: const [], pendingRequests: const [])),
        );

        expect(find.text(aed('0.00')), findsOneWidget);
        expect(find.text('No payments yet'), findsOneWidget);
        expect(find.text('See all'), findsNothing);
      });
    });

    testWidgets('lists requests waiting for approval without revealing their amounts', (
      tester,
    ) async {
      await withClock(Clock.fixed(tNow), () async {
        final pending = tRequest(reference: 'PAY-40117', maskedRecipient: 'A•••• K.');

        await pumpHome(tester, PaymentsLoaded(tWireframeSnapshot.withPendingRequest(pending)));

        expect(find.text('WAITING FOR YOUR APPROVAL'), findsOneWidget);
        expect(find.text('A•••• K.'), findsOneWidget);
        expect(find.text('Ref PAY-40117'), findsOneWidget);
      });
    });

    testWidgets('reopens the approval sheet when a waiting request is tapped', (tester) async {
      await withClock(Clock.fixed(tNow), () async {
        final pending = tRequest(reference: 'PAY-40117');
        await pumpHome(tester, PaymentsLoaded(tWireframeSnapshot.withPendingRequest(pending)));

        await tester.tap(find.text('Ref PAY-40117'));

        verify(() => presenter.review(pending)).called(1);
      });
    });

    testWidgets('hides the waiting section when nothing is pending', (tester) async {
      await withClock(Clock.fixed(tNow), () async {
        await pumpHome(tester, PaymentsLoaded(tWireframeSnapshot));

        expect(find.text('WAITING FOR YOUR APPROVAL'), findsNothing);
      });
    });

    testWidgets('retries when loading failed', (tester) async {
      await pumpHome(tester, const PaymentsLoadFailure());

      await tester.tap(find.text('Try again'));

      verify(() => bloc.add(const PaymentsStarted())).called(1);
    });

    testWidgets('lays out right to left without overflowing', (tester) async {
      await withClock(Clock.fixed(tNow), () async {
        await pumpHome(
          tester,
          PaymentsLoaded(tWireframeSnapshot),
          textDirection: TextDirection.rtl,
        );

        expect(tester.takeException(), isNull);
        expect(find.text(aed('1,540.00')), findsOneWidget);
      });
    });
  });
}
