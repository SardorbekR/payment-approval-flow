import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/core/theme/app_theme.dart';
import 'package:payment_approval/features/payments/presentation/bloc/payments_bloc.dart';
import 'package:payment_approval/l10n/app_localizations.dart';

class MockPaymentsBloc extends MockBloc<PaymentsEvent, PaymentsState> implements PaymentsBloc {}

/// Wraps a page the way the app does: theme, localizations and the shared bloc.
Widget testApp({
  required Widget child,
  PaymentsBloc? paymentsBloc,
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

  return paymentsBloc == null ? app : BlocProvider.value(value: paymentsBloc, child: app);
}

/// Amounts are formatted with a non-breaking space after the currency code.
String aed(String amount) => 'AED $amount';
