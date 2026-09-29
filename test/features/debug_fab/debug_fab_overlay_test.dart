import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:payment_approval/features/debug_fab/debug_fab_overlay.dart';
import 'package:payment_approval/features/payments/presentation/bloc/payments_bloc.dart';

import '../../helpers/test_app.dart';
import '../payments/payments_seed.dart';

void main() {
  late MockPaymentsBloc bloc;
  late MockApprovalPresenter presenter;
  late ValueNotifier<bool> isBusy;

  setUp(() {
    bloc = MockPaymentsBloc();
    presenter = MockApprovalPresenter();
    isBusy = ValueNotifier(false);
    when(() => presenter.isBusy).thenReturn(isBusy);
    when(() => presenter.simulateIncomingRequest()).thenAnswer((_) async {});
  });

  tearDown(() => isBusy.dispose());

  Finder fab() => find.byIcon(Icons.add_rounded);

  Future<void> pumpOverlay(
    WidgetTester tester, {
    PaymentsState state = const PaymentsLoading(),
    Widget child = const Text('Screen below'),
  }) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    whenListen(bloc, const Stream<PaymentsState>.empty(), initialState: state);

    await tester.pumpWidget(
      testApp(
        paymentsBloc: bloc,
        child: DebugFabOverlay(presenter: presenter, child: child),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('DebugFabOverlay', () {
    testWidgets('floats over the screen once payments have loaded', (tester) async {
      await pumpOverlay(tester, state: PaymentsLoaded(tWireframeSnapshot));

      expect(fab().hitTestable(), findsOneWidget);
    });

    testWidgets('is announced to screen readers as a labeled button', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpOverlay(tester, state: PaymentsLoaded(tWireframeSnapshot));

      expect(
        tester.getSemantics(find.bySemanticsLabel('Simulate an incoming payment request')),
        isSemantics(
          label: 'Simulate an incoming payment request',
          isButton: true,
          hasTapAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('stays hidden until payments have loaded', (tester) async {
      await pumpOverlay(tester);

      expect(fab().hitTestable(), findsNothing);
    });

    testWidgets('hides while a request is on screen and comes back afterwards', (tester) async {
      await pumpOverlay(tester, state: PaymentsLoaded(tWireframeSnapshot));

      isBusy.value = true;
      await tester.pumpAndSettle();
      expect(fab().hitTestable(), findsNothing);

      isBusy.value = false;
      await tester.pumpAndSettle();
      expect(fab().hitTestable(), findsOneWidget);
    });

    testWidgets('asks for a new incoming request when tapped', (tester) async {
      await pumpOverlay(tester, state: PaymentsLoaded(tWireframeSnapshot));

      await tester.tap(fab());

      verify(() => presenter.simulateIncomingRequest()).called(1);
    });

    testWidgets('moves where it is dragged, without asking for a request', (tester) async {
      await pumpOverlay(tester, state: PaymentsLoaded(tWireframeSnapshot));
      final start = tester.getCenter(fab());

      await tester.drag(fab(), const Offset(-150, -300));
      await tester.pump();

      expect(tester.getCenter(fab()), start + const Offset(-150, -300));
      verifyNever(() => presenter.simulateIncomingRequest());
    });

    testWidgets('stays where it was left when the screen below changes', (tester) async {
      await pumpOverlay(tester, state: PaymentsLoaded(tWireframeSnapshot));
      await tester.drag(fab(), const Offset(-150, -300));
      await tester.pump();
      final moved = tester.getCenter(fab());

      await pumpOverlay(
        tester,
        state: PaymentsLoaded(tWireframeSnapshot),
        child: const Text('Another screen'),
      );

      expect(tester.getCenter(fab()), moved);
    });

    testWidgets('cannot be dragged off screen', (tester) async {
      await pumpOverlay(tester, state: PaymentsLoaded(tWireframeSnapshot));

      await tester.drag(fab(), const Offset(2000, 2000));
      await tester.pump();

      final bounds = tester.getRect(find.byType(DebugFabOverlay));
      final button = tester.getRect(
        find.ancestor(of: fab(), matching: find.byType(Material)).first,
      );
      expect(
        bounds.contains(button.topLeft) && bounds.contains(button.bottomRight - const Offset(1, 1)),
        isTrue,
      );
    });

    testWidgets('moves back on screen when the window shrinks', (tester) async {
      await pumpOverlay(tester, state: PaymentsLoaded(tWireframeSnapshot));

      tester.view.physicalSize = const Size(320, 480);
      await tester.pump();

      final button = tester.getRect(
        find.ancestor(of: fab(), matching: find.byType(Material)).first,
      );
      expect(button.right, lessThanOrEqualTo(320));
      expect(button.bottom, lessThanOrEqualTo(480));
    });
  });
}
