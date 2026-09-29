import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/core/device_auth/device_authenticator.dart';
import 'package:payment_approval/features/approval/presentation/bloc/approval_bloc.dart';
import 'package:payment_approval/features/approval/presentation/widgets/approval_sheet.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';
import 'package:payment_approval/features/payments/domain/models/payment_request.dart';
import 'package:payment_approval/features/payments/domain/repositories/payments_repository.dart';
import 'package:payment_approval/l10n/app_localizations.dart';
import 'package:payment_approval/router.dart';

/// Owns the one piece of UI that can interrupt any screen: the approval sheet.
///
/// The debug button and the pending rows on Home both go through it, so only one
/// sheet is ever open. [isBusy] stays true while a request is on its way or its
/// sheet is open, and the debug button hides during that time.
class ApprovalPresenter {
  ApprovalPresenter({
    required GlobalKey<NavigatorState> navigatorKey,
    required GlobalKey<ScaffoldMessengerState> messengerKey,
    required GoRouter router,
    required PaymentsRepository repository,
    required DeviceAuthenticator authenticator,
  }) : _navigatorKey = navigatorKey,
       _messengerKey = messengerKey,
       _router = router,
       _repository = repository,
       _authenticator = authenticator;

  final GlobalKey<NavigatorState> _navigatorKey;
  final GlobalKey<ScaffoldMessengerState> _messengerKey;
  final GoRouter _router;
  final PaymentsRepository _repository;
  final DeviceAuthenticator _authenticator;
  final _isBusy = ValueNotifier(false);

  ValueListenable<bool> get isBusy => _isBusy;

  /// Asks the server for a new request and shows it over the current screen.
  Future<void> simulateIncomingRequest() => _present(_repository.createDebugRequest);

  /// Shows a request that is still waiting for a decision.
  Future<void> review(PaymentRequest request) => _present(() async => request);

  void dispose() => _isBusy.dispose();

  Future<void> _present(Future<PaymentRequest> Function() obtainRequest) async {
    if (_isBusy.value) return;
    _isBusy.value = true;
    // Whatever the last snackbar said about a request is out of date once a sheet opens.
    _messengerKey.currentState?.hideCurrentSnackBar();

    try {
      final PaymentRequest request;
      try {
        request = await obtainRequest();
      } on Exception {
        _showSnackBar((l10n) => l10n.incomingRequestFailedSnack);
        return;
      }

      // The presenter owns the bloc, so a decision outlives its sheet.
      final bloc = ApprovalBloc(
        request: request,
        repository: _repository,
        authenticator: _authenticator,
      );
      final Payment? outcome;
      try {
        outcome = await _showSheet(request, bloc) ?? await _outcomeOfDecisionInFlight(bloc);
      } finally {
        await bloc.close();
      }

      if (outcome == null) {
        _onClosedWithoutDecision(request);
        return;
      }
      final decided = outcome;

      // The sheet has already closed here, so navigating can't leave it behind.
      switch (decided.status) {
        case PaymentStatus.approved:
          _router.goNamed(Routes.payments.name);
          _showSnackBar((l10n) => l10n.paymentApprovedSnack(decided.reference));
        case PaymentStatus.rejected:
          // Rejecting keeps the user where they were.
          _showSnackBar(
            (l10n) => l10n.paymentRejectedSnack(decided.reference),
            action: (l10n) => SnackBarAction(
              label: l10n.viewAction,
              onPressed: () => _router.pushNamed(
                Routes.paymentDetails.name,
                pathParameters: {'id': decided.id},
              ),
            ),
          );
      }
    } finally {
      _isBusy.value = false;
    }
  }

  /// Returns the decided payment, or null when the sheet closed without a decision.
  Future<Payment?> _showSheet(PaymentRequest request, ApprovalBloc bloc) {
    final context = _navigatorKey.currentContext;
    if (context == null) return Future.value();

    return showModalBottomSheet<Payment>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      // Dragging closes a sheet without asking PopScope, even mid-decision, so
      // it closes through its button, a tap outside or back instead.
      enableDrag: false,
      showDragHandle: false,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: ApprovalSheet(request: request),
      ),
    );
  }

  /// The sheet can disappear without an answer while a decision is running,
  /// for example when the browser's back button removes the page under it.
  /// The decision carries on, so wait for its outcome instead of reporting the
  /// request as still pending.
  Future<Payment?> _outcomeOfDecisionInFlight(ApprovalBloc bloc) async {
    bool inFlight(ApprovalState state) =>
        state is ApprovalAuthenticating || state is ApprovalSubmitting;

    final outcome = inFlight(bloc.state)
        ? await bloc.stream.firstWhere((state) => !inFlight(state))
        : bloc.state;

    return outcome is ApprovalSuccess ? outcome.payment : null;
  }

  void _onClosedWithoutDecision(PaymentRequest request) {
    // A request the server no longer has is already gone, so there's nothing to come back to.
    if (!_repository.isPending(request.id)) return;

    _showSnackBar(
      (l10n) => l10n.paymentStillPendingSnack(request.reference),
      action: (l10n) => SnackBarAction(label: l10n.reviewAction, onPressed: () => review(request)),
    );
  }

  void _showSnackBar(
    String Function(AppLocalizations l10n) message, {
    SnackBarAction Function(AppLocalizations l10n)? action,
  }) {
    final context = _navigatorKey.currentContext;
    final messenger = _messengerKey.currentState;
    if (context == null || messenger == null) return;

    final l10n = AppLocalizations.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message(l10n)),
          action: action?.call(l10n),
          // Every action is also reachable from Home or Payments, so the snackbar
          // times out like any other. Screen reader users get time to reach it.
          persist: MediaQuery.accessibleNavigationOf(context),
        ),
      );
  }
}
