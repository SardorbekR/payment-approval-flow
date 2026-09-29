import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/core/formatting/date_formatter.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';
import 'package:payment_approval/features/payments/presentation/bloc/payments_bloc.dart';
import 'package:payment_approval/features/payments/presentation/widgets/payment_tile.dart';
import 'package:payment_approval/features/payments/presentation/widgets/payments_load_failure_view.dart';
import 'package:payment_approval/features/shared/widgets/message_view.dart';
import 'package:payment_approval/features/shared/widgets/section_card.dart';
import 'package:payment_approval/features/shared/widgets/section_header.dart';
import 'package:payment_approval/l10n/app_localizations.dart';
import 'package:payment_approval/router.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final _scrollController = ScrollController();
  String? _highlightedPaymentId;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// A payment that wasn't in the list before is now on top: the user just decided it.
  bool _hasNewTopPayment(PaymentsState previous, PaymentsState current) {
    if (previous is! PaymentsLoaded || current is! PaymentsLoaded) return false;

    final top = current.snapshot.payments.firstOrNull;

    return top != null && previous.snapshot.paymentById(top.id) == null;
  }

  /// The tab keeps its scroll position, so a new payment could land above the
  /// visible area. Scroll back to the top and highlight it.
  void _revealTopPayment(BuildContext context, PaymentsState state) {
    final top = (state as PaymentsLoaded).snapshot.payments.first;
    setState(() => _highlightedPaymentId = top.id);

    if (!_scrollController.hasClients) return;
    // A tab in the background has its tickers muted, so an animation would stall.
    if (TickerMode.getValuesNotifier(context).value.enabled) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.paymentsTitle),
        titleTextStyle: Theme.of(context).textTheme.headlineSmall,
      ),
      body: BlocConsumer<PaymentsBloc, PaymentsState>(
        listenWhen: _hasNewTopPayment,
        listener: _revealTopPayment,
        builder: (context, state) => switch (state) {
          PaymentsLoading() => const Center(child: CircularProgressIndicator()),
          PaymentsLoadFailure() => const PaymentsLoadFailureView(),
          PaymentsLoaded(:final snapshot) when snapshot.payments.isEmpty => MessageView(
            icon: Icons.receipt_long_outlined,
            title: l10n.noPaymentsTitle,
            message: l10n.noPaymentsMessage,
          ),
          PaymentsLoaded(:final snapshot) => _PaymentsList(
            payments: snapshot.payments,
            controller: _scrollController,
            highlightedPaymentId: _highlightedPaymentId,
          ),
        },
      ),
    );
  }
}

/// Payments grouped by the month they were decided in, most recent first.
class _PaymentsList extends StatelessWidget {
  const _PaymentsList({
    required this.payments,
    required this.controller,
    required this.highlightedPaymentId,
  });

  final List<Payment> payments;
  final ScrollController controller;
  final String? highlightedPaymentId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final months = <DateTime, List<Payment>>{};
    for (final payment in payments) {
      final decidedAt = payment.decidedAt.toLocal();
      months.putIfAbsent(DateTime(decidedAt.year, decidedAt.month), () => []).add(payment);
    }

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 168),
      children: [
        for (final MapEntry(key: month, value: monthPayments) in months.entries) ...[
          SectionHeader(title: formatMonthYear(month, l10n: l10n)),
          SectionCard(
            children: [
              for (final payment in monthPayments)
                PaymentTile(
                  key: ValueKey(payment.id),
                  payment: payment,
                  highlighted: payment.id == highlightedPaymentId,
                  onTap: () => context.pushNamed(
                    Routes.paymentDetails.name,
                    pathParameters: {'id': payment.id},
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
