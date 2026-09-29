import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/features/payments/domain/models/payments_snapshot.dart';
import 'package:payment_approval/features/payments/presentation/bloc/payments_bloc.dart';
import 'package:payment_approval/features/payments/presentation/pages/payment_details_page.dart';
import 'package:payment_approval/features/shared/widgets/section_card.dart';

import '../../../../helpers/test_app.dart';
import '../../payments_seed.dart';

void main() {
  late MockPaymentsBloc bloc;

  setUp(() {
    bloc = MockPaymentsBloc();
  });

  Future<void> pumpDetails(WidgetTester tester, String paymentId, PaymentsState state) async {
    whenListen(bloc, const Stream<PaymentsState>.empty(), initialState: state);
    await tester.pumpWidget(
      testApp(
        child: PaymentDetailsPage(paymentId: paymentId),
        paymentsBloc: bloc,
      ),
    );
  }

  group('PaymentDetailsPage', () {
    testWidgets('shows the full details of a decided payment', (tester) async {
      await pumpDetails(tester, 'pay_ahmed', PaymentsLoaded(tWireframeSnapshot));

      expect(find.text('Ahmed Khalil'), findsOneWidget);
      expect(find.text(aed('1,200.00')), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);
      expect(find.text('PAY-88213'), findsOneWidget);
      expect(find.text('Design retainer'), findsOneWidget);
      expect(find.textContaining('Sep 26, 2026'), findsOneWidget);
    });

    testWidgets('keeps the amount on one line when the text is large', (tester) async {
      usePhoneScreen(tester, textScale: 2);
      await pumpDetails(tester, 'pay_ahmed', PaymentsLoaded(tWireframeSnapshot));

      final amount = find.text(aed('1,200.00'));
      final paragraph = tester.renderObject<RenderParagraph>(amount);
      final lines = paragraph.getBoxesForSelection(
        TextSelection(baseOffset: 0, extentOffset: paragraph.text.toPlainText().length),
      );
      expect({for (final box in lines) box.top}, hasLength(1));
      expect(tester.getRect(amount).width, lessThanOrEqualTo(390));
    });

    testWidgets('gives every detail row the same height', (tester) async {
      await pumpDetails(tester, 'pay_ahmed', PaymentsLoaded(tWireframeSnapshot));

      final card = tester.getRect(find.byType(SectionCard));
      final dividers = find.descendant(
        of: find.byType(SectionCard),
        matching: find.byType(Divider),
      );
      final first = tester.getRect(dividers.at(0));
      final second = tester.getRect(dividers.at(1));

      final heights = [
        first.top - card.top,
        second.top - first.bottom,
        card.bottom - second.bottom,
      ];
      expect(heights.toSet(), hasLength(1));
    });

    testWidgets('explains that a rejected payment moved no money', (tester) async {
      await pumpDetails(tester, 'pay_leo', PaymentsLoaded(tWireframeSnapshot));

      expect(find.text('Rejected'), findsOneWidget);
      expect(find.text('Rejected, so no money moved.'), findsOneWidget);
    });

    testWidgets('never opens a request that is still waiting for approval', (tester) async {
      final snapshot = PaymentsSnapshot(
        payments: tWireframeSnapshot.payments,
        pendingRequests: [tRequest(id: 'pay_pending')],
      );

      await pumpDetails(tester, 'pay_pending', PaymentsLoaded(snapshot));

      expect(find.text('Payment unavailable'), findsOneWidget);
    });

    testWidgets('shows payment unavailable for an unknown id', (tester) async {
      await pumpDetails(tester, 'pay_missing', PaymentsLoaded(tWireframeSnapshot));

      expect(find.text('Payment unavailable'), findsOneWidget);
    });

    testWidgets('waits for payments to load before deciding anything', (tester) async {
      await pumpDetails(tester, 'pay_ahmed', const PaymentsLoading());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Payment unavailable'), findsNothing);
    });

    testWidgets('copies the reference', (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (
        call,
      ) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map<Object?, Object?>)['text'] as String?;
        }
        return null;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await pumpDetails(tester, 'pay_ahmed', PaymentsLoaded(tWireframeSnapshot));

      await tester.tap(find.byTooltip('Copy reference'));
      await tester.pump();

      expect(copied, 'PAY-88213');
      expect(find.text('Reference copied'), findsOneWidget);
    });
  });
}
