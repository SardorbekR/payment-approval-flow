import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/core/theme/app_theme.dart';
import 'package:payment_approval/features/payments/data/repositories/payments_repository.dart';
import 'package:payment_approval/features/payments/presentation/bloc/payments_bloc.dart';
import 'package:payment_approval/l10n/app_localizations.dart';
import 'package:payment_approval/router.dart';

class App extends StatefulWidget {
  const App({required this.navigatorKey, required this.repository, super.key});

  final GlobalKey<NavigatorState> navigatorKey;
  final PaymentsRepository repository;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router = createRouter(navigatorKey: widget.navigatorKey);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const theme = AppTheme();

    return RepositoryProvider.value(
      value: widget.repository,
      child: BlocProvider(
        create: (_) => PaymentsBloc(repository: widget.repository)..add(const PaymentsStarted()),
        child: MaterialApp.router(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          theme: theme.light(),
          darkTheme: theme.dark(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: _router,
        ),
      ),
    );
  }
}
