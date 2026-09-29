import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/core/formatting/date_formatter.dart';
import 'package:payment_approval/core/formatting/money_formatter.dart';
import 'package:payment_approval/core/theme/app_theme.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';
import 'package:payment_approval/features/payments/presentation/bloc/payments_bloc.dart';
import 'package:payment_approval/features/payments/presentation/widgets/payments_load_failure_view.dart';
import 'package:payment_approval/features/shared/widgets/message_view.dart';
import 'package:payment_approval/features/shared/widgets/recipient_avatar.dart';
import 'package:payment_approval/features/shared/widgets/section_card.dart';
import 'package:payment_approval/features/shared/widgets/status_badge.dart';
import 'package:payment_approval/l10n/app_localizations.dart';
import 'package:payment_approval/router.dart';

class PaymentDetailsPage extends StatelessWidget {
  const PaymentDetailsPage({required this.paymentId, super.key});

  final String paymentId;

  /// A details link opened directly (on the web) has nothing to go back to.
  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(Routes.home.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => _goBack(context)),
        title: Text(l10n.paymentDetailsTitle),
      ),
      body: BlocBuilder<PaymentsBloc, PaymentsState>(
        builder: (context, state) => switch (state) {
          PaymentsLoading() => const Center(child: CircularProgressIndicator()),
          PaymentsLoadFailure() => const PaymentsLoadFailureView(),
          // Only decided payments resolve. A pending request isn't a payment
          // yet, so its id lands here as unavailable.
          PaymentsLoaded(:final snapshot) => switch (snapshot.paymentById(paymentId)) {
            final payment? => _PaymentDetails(payment: payment),
            null => MessageView(
              icon: Icons.lock_clock_outlined,
              title: l10n.paymentUnavailableTitle,
              message: l10n.paymentUnavailableMessage,
              actionLabel: l10n.goToPayments,
              onAction: () => context.goNamed(Routes.payments.name),
            ),
          },
        },
      ),
    );
  }
}

class _PaymentDetails extends StatelessWidget {
  const _PaymentDetails({required this.payment});

  final Payment payment;

  Future<void> _copyReference(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmation = AppLocalizations.of(context).referenceCopied;
    await Clipboard.setData(ClipboardData(text: payment.reference));
    messenger.showSnackBar(SnackBar(content: Text(confirmation)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isRejected = payment.status == PaymentStatus.rejected;
    final note = payment.note;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 248),
      children: [
        // Header
        Center(child: RecipientAvatar(name: payment.recipientName, size: 64)),
        const SizedBox(height: 12),
        Text(
          payment.recipientName,
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Center(child: StatusBadge(status: payment.status)),
        const SizedBox(height: 20),
        Text(
          formatMoney(payment.amount),
          textAlign: TextAlign.center,
          style: theme.textTheme.displaySmall?.tabular.copyWith(
            color: isRejected ? theme.colorScheme.onSurfaceVariant : null,
          ),
        ),
        if (isRejected) ...[
          const SizedBox(height: 6),
          Text(
            l10n.detailsRejectedHint,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 28),

        // Details
        SectionCard(
          children: [
            _DetailRow(
              label: l10n.detailsDate,
              value: formatFullDate(payment.decidedAt, l10n: l10n),
            ),
            _DetailRow(
              label: l10n.detailsReference,
              value: payment.reference,
              trailing: IconButton(
                tooltip: l10n.copyReference,
                icon: const Icon(Icons.copy_rounded, size: 18),
                onPressed: () => _copyReference(context),
              ),
            ),
            if (note != null) _DetailRow(label: l10n.detailsNote, value: note),
          ],
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.trailing});

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16, 14, trailing == null ? 16 : 4, 14),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
