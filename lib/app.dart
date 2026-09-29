import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/core/device_auth/device_authenticator.dart';
import 'package:payment_approval/core/theme/app_theme.dart';
import 'package:payment_approval/features/approval/presentation/approval_presenter.dart';
import 'package:payment_approval/features/debug_fab/debug_fab_overlay.dart';
import 'package:payment_approval/features/payments/domain/repositories/payments_repository.dart';
import 'package:payment_approval/features/payments/presentation/bloc/payments_bloc.dart';
import 'package:payment_approval/features/shared/widgets/demo_frame.dart';
import 'package:payment_approval/l10n/app_localizations.dart';
import 'package:payment_approval/router.dart';

class App extends StatefulWidget {
  const App({
    required this.navigatorKey,
    required this.repository,
    required this.authenticator,
    this.showDemoFrame = kIsWeb,
    super.key,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final PaymentsRepository repository;
  final DeviceAuthenticator authenticator;

  /// Wraps the app in [DemoFrame] on wide browser windows
  final bool showDemoFrame;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  // Keeps the debug button's position when the web frame comes and goes on resize
  final _debugFabKey = GlobalKey();
  late final GoRouter _router = createRouter(navigatorKey: widget.navigatorKey);
  late final _presenter = ApprovalPresenter(
    navigatorKey: widget.navigatorKey,
    messengerKey: _messengerKey,
    router: _router,
    repository: widget.repository,
    authenticator: widget.authenticator,
  );

  @override
  void dispose() {
    _presenter.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const theme = AppTheme();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.repository),
        RepositoryProvider.value(value: _presenter),
      ],
      child: BlocProvider(
        create: (_) => PaymentsBloc(repository: widget.repository)..add(const LoadPayments()),
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
          scaffoldMessengerKey: _messengerKey,
          routerConfig: _router,
          builder: (context, child) => DemoFrame(
            enabled: widget.showDemoFrame,
            child: DebugFabOverlay(key: _debugFabKey, presenter: _presenter, child: child!),
          ),
        ),
      ),
    );
  }
}
