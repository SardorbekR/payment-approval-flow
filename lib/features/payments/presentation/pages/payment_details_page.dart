import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/core/formatting/date_formatter.dart';
import 'package:payment_approval/core/formatting/money_formatter.dart';
import 'package:payment_approval/core/theme/app_theme.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';
import 'package:payment_approval/features/payments/presentation/bloc/payments_bloc.dart';
import 'package:payment_approval/features/payments/presentation/widgets/payments_error_view.dart';
import 'package:payment_approval/features/shared/widgets/labeled_value.dart';
import 'package:payment_approval/features/shared/widgets/message_view.dart';
import 'package:payment_approval/features/shared/widgets/recipient_avatar.dart';
import 'package:payment_approval/features/shared/widgets/section_card.dart';
import 'package:payment_approval/features/shared/widgets/status_badge.dart';
import 'package:payment_approval/l10n/app_localizations.dart';
import 'package:payment_approval/router.dart';

class PaymentDetailsPage extends StatelessWidget {
  const PaymentDetailsPage({required this.paymentId, super.key});

  final String paymentId;

  /// A link opened directly has nothing to go back to
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
      // Clears the notch in landscape
      body: SafeArea(
        top: false,
        bottom: false,
        child: BlocBuilder<PaymentsBloc, PaymentsState>(
          builder: (context, state) => switch (state) {
            PaymentsInitial() || PaymentsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            PaymentsError() => const PaymentsErrorView(),
            // A pending request isn't a payment yet, so it shows as unavailable
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
      // Leaves room for the debug button, measured from the safe area
      padding: EdgeInsets.fromLTRB(16, 16, 16, 168 + MediaQuery.paddingOf(context).bottom),
      children: [
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
        // Shrinks with large text instead of wrapping mid-number
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            formatMoney(payment.amount),
            style: theme.textTheme.displaySmall?.tabular.copyWith(
              color: isRejected ? theme.colorScheme.onSurfaceVariant : null,
            ),
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
      // The icon button's own padding lines its icon up with the values
      padding: EdgeInsetsDirectional.fromSTEB(16, 4, trailing == null ? 16 : 0, 4),
      child: ConstrainedBox(
        // As tall as an icon button, so all rows match
        constraints: const BoxConstraints(minHeight: 48),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: LabeledValue(
            label: label,
            value: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
