import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:payment_approval/features/approval/presentation/bloc/approval_bloc.dart';
import 'package:payment_approval/features/approval/presentation/widgets/approval_sheet.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';

import '../../../../helpers/test_app.dart';
import '../../../payments/payments_seed.dart';

class MockApprovalBloc extends MockBloc<ApprovalEvent, ApprovalState> implements ApprovalBloc {}

void main() {
  late MockApprovalBloc bloc;
  final request = tRequest(id: 'pay_req', reference: 'PAY-40117', maskedRecipient: 'A•••• K.');

  setUpAll(() {
    registerFallbackValue(const SubmitDecision(PaymentStatus.approved, authReason: ''));
  });

  setUp(() {
    bloc = MockApprovalBloc();
  });

  Future<void> pumpSheet(WidgetTester tester, ApprovalState state) async {
    whenListen(bloc, const Stream<ApprovalState>.empty(), initialState: state);
    await tester.pumpWidget(
      testApp(
        child: Scaffold(
          body: BlocProvider<ApprovalBloc>.value(
            value: bloc,
            child: ApprovalSheet(request: request),
          ),
        ),
      ),
    );
  }

  VoidCallback? onPressedOf<T extends ButtonStyleButton>(WidgetTester tester) =>
      tester.widget<T>(find.byType(T)).onPressed;

  group('ApprovalSheet', () {
    testWidgets('shows the reference in full and hides the recipient and the amount', (
      tester,
    ) async {
      await pumpSheet(tester, const ApprovalInitial());

      expect(find.text('PAY-40117'), findsOneWidget);
      expect(find.text('A•••• K.'), findsOneWidget);
      expect(find.text(aed('••,•••.••')), findsOneWidget);
    });

    testWidgets('moves a value under its label rather than breaking it when the text is large', (
      tester,
    ) async {
      usePhoneScreen(tester, textScale: 2);
      await pumpSheet(tester, const ApprovalInitial());

      final label = tester.getRect(find.text('Reference'));
      final value = tester.getRect(find.text('PAY-40117'));
      expect(value.top, greaterThanOrEqualTo(label.bottom));
      expect(value.left, label.left);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tells screen readers the values are hidden instead of reading bullets', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpSheet(tester, const ApprovalInitial());

      expect(find.bySemanticsLabel('To: Recipient hidden until you authenticate'), findsOneWidget);
      expect(find.bySemanticsLabel('Amount: Amount hidden until you authenticate'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('asks the device with a reason that names the reference', (tester) async {
      await pumpSheet(tester, const ApprovalInitial());

      await tester.tap(find.text('Approve'));

      final event = verify(() => bloc.add(captureAny())).captured.single as SubmitDecision;
      expect(event.decision, PaymentStatus.approved);
      expect(event.authReason, "Confirm it's you to approve payment PAY-40117");
    });

    testWidgets('locks both decisions and closing while a decision is in progress', (
      tester,
    ) async {
      await pumpSheet(tester, const ApprovalSubmitting(PaymentStatus.approved));

      expect(onPressedOf<FilledButton>(tester), isNull);
      expect(onPressedOf<OutlinedButton>(tester), isNull);
      expect(tester.widget<IconButton>(find.byType(IconButton)).onPressed, isNull);
      expect(tester.widget<PopScope>(find.byType(PopScope)).canPop, isFalse);
      expect(find.text('Approving…'), findsOneWidget);
    });

    testWidgets('says it is waiting for the device while authenticating', (tester) async {
      await pumpSheet(tester, const ApprovalAuthenticating(PaymentStatus.rejected));

      expect(find.text('Waiting for device authentication…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('explains a failure and lets the user try again', (tester) async {
      await pumpSheet(
        tester,
        const ApprovalError(PaymentStatus.approved, ApprovalErrorReason.authUnavailable),
      );

      expect(find.textContaining('Set up a screen lock'), findsOneWidget);
      expect(onPressedOf<FilledButton>(tester), isNotNull);
      expect(tester.widget<PopScope>(find.byType(PopScope)).canPop, isTrue);
    });

    testWidgets('offers only Close for a request that is gone', (tester) async {
      await pumpSheet(
        tester,
        const ApprovalError(PaymentStatus.approved, ApprovalErrorReason.requestUnavailable),
      );

      expect(find.textContaining('no longer available'), findsOneWidget);
      expect(find.text('Approve'), findsNothing);
      expect(find.text('Reject'), findsNothing);
      expect(find.text('Close'), findsOneWidget);
    });
  });
}
