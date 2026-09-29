import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:payment_approval/core/theme/app_theme.dart';
import 'package:payment_approval/features/approval/presentation/approval_presenter.dart';
import 'package:payment_approval/features/payments/presentation/bloc/payments_bloc.dart';
import 'package:payment_approval/l10n/app_localizations.dart';

class MockPaymentsBloc extends MockBloc<PaymentsEvent, PaymentsState> implements PaymentsBloc {}

class MockApprovalPresenter extends Mock implements ApprovalPresenter {}

/// Wraps a page like the app does, with the theme, localizations and shared bloc
Widget testApp({
  required Widget child,
  PaymentsBloc? paymentsBloc,
  ApprovalPresenter? presenter,
  Brightness brightness = Brightness.light,
  TextDirection textDirection = TextDirection.ltr,
}) {
  const theme = AppTheme();
  final app = MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: brightness == Brightness.light ? theme.light() : theme.dark(),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => Directionality(textDirection: textDirection, child: child!),
    home: child,
  );

  final withBloc = paymentsBloc == null ? app : BlocProvider.value(value: paymentsBloc, child: app);

  return presenter == null ? withBloc : RepositoryProvider.value(value: presenter, child: withBloc);
}

/// Uses a phone sized screen, with an optional larger text size
void usePhoneScreen(WidgetTester tester, {double textScale = 1}) {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

/// Amounts are formatted with a non-breaking space after the currency code
String aed(String amount) => 'AED\u00A0$amount';
