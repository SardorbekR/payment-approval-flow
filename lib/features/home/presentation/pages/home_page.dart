import 'package:clock/clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/features/home/presentation/widgets/monthly_summary_card.dart';
import 'package:payment_approval/features/home/presentation/widgets/pending_requests_section.dart';
import 'package:payment_approval/features/payments/domain/models/money.dart';
import 'package:payment_approval/features/payments/domain/models/monthly_summary.dart';
import 'package:payment_approval/features/payments/domain/models/payments_snapshot.dart';
import 'package:payment_approval/features/payments/presentation/bloc/payments_bloc.dart';
import 'package:payment_approval/features/payments/presentation/widgets/payment_tile.dart';
import 'package:payment_approval/features/payments/presentation/widgets/payments_error_view.dart';
import 'package:payment_approval/features/shared/widgets/message_view.dart';
import 'package:payment_approval/features/shared/widgets/section_card.dart';
import 'package:payment_approval/features/shared/widgets/section_header.dart';
import 'package:payment_approval/l10n/app_localizations.dart';
import 'package:payment_approval/router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const recentLimit = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        titleTextStyle: Theme.of(context).textTheme.headlineSmall,
      ),
      // Keeps the content clear of a notch in landscape.
      body: SafeArea(
        top: false,
        bottom: false,
        child: BlocBuilder<PaymentsBloc, PaymentsState>(
          builder: (context, state) => switch (state) {
            PaymentsLoading() => const Center(child: CircularProgressIndicator()),
            PaymentsError() => const PaymentsErrorView(),
            PaymentsLoaded(:final snapshot) => _HomeContent(snapshot: snapshot),
          },
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.snapshot});

  final PaymentsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final payments = snapshot.payments;
    final recent = payments.take(HomePage.recentLimit);

    return ListView(
      // Leaves room for the debug button in its default spot.
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
      children: [
        // Summary
        MonthlySummaryCard(
          summary: MonthlySummary.of(payments, now: clock.now(), currency: Currency.aed),
        ),

        // Requests closed without a decision
        if (snapshot.pendingRequests.isNotEmpty)
          PendingRequestsSection(requests: snapshot.pendingRequests),

        // Recent payments
        SectionHeader(
          title: l10n.recentTitle,
          trailing: payments.isEmpty
              ? null
              : TextButton(
                  onPressed: () => context.goNamed(Routes.payments.name),
                  child: Text(l10n.seeAll),
                ),
        ),
        SectionCard(
          children: [
            if (recent.isEmpty)
              MessageView(
                icon: Icons.receipt_long_outlined,
                title: l10n.noPaymentsTitle,
                message: l10n.noPaymentsMessage,
              )
            else
              for (final payment in recent)
                PaymentTile(
                  key: ValueKey(payment.id),
                  payment: payment,
                  onTap: () => context.pushNamed(
                    Routes.paymentDetails.name,
                    pathParameters: {'id': payment.id},
                  ),
                ),
          ],
        ),
      ],
    );
  }
}
