import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/core/formatting/money_formatter.dart';
import 'package:payment_approval/core/theme/app_theme.dart';
import 'package:payment_approval/features/approval/presentation/bloc/approval_bloc.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';
import 'package:payment_approval/features/payments/domain/models/payment_request.dart';
import 'package:payment_approval/l10n/app_localizations.dart';

/// Asks the user to approve or reject a request without revealing who it pays
/// or how much. Pops with the decided [Payment] once the decision is recorded.
class ApprovalSheet extends StatelessWidget {
  const ApprovalSheet({required this.request, super.key});

  final PaymentRequest request;

  void _submit(BuildContext context, PaymentStatus decision) {
    final l10n = AppLocalizations.of(context);
    final reason = switch (decision) {
      PaymentStatus.approved => l10n.authReasonApprove(request.reference),
      PaymentStatus.rejected => l10n.authReasonReject(request.reference),
    };

    context.read<ApprovalBloc>().add(ApprovalSubmitted(decision, authReason: reason));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<ApprovalBloc, ApprovalState>(
      listenWhen: (previous, current) => current is ApprovalSucceeded,
      listener: (context, state) => Navigator.of(context).pop((state as ApprovalSucceeded).payment),
      builder: (context, state) {
        final isBusy = state.isBusy;
        final isRequestGone =
            state is ApprovalFailed && state.error == ApprovalError.requestUnavailable;
        final pendingDecision = switch (state) {
          ApprovalAuthenticating(:final decision) ||
          ApprovalSubmitting(:final decision) => decision,
          _ => null,
        };

        return PopScope(
          // Closing mid-decision would hide whether the decision went through.
          canPop: !isBusy,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Title and close
                Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(l10n.approvalTitle, style: theme.textTheme.titleLarge),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.decideLater,
                      onPressed: isBusy ? null : () => Navigator.maybePop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                /// Masked request
                _MaskedRequestCard(request: request),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(l10n.approvalHiddenNote, style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                /// Outcome
                if (state is ApprovalFailed) ...[
                  _ErrorMessage(error: state.error),
                  const SizedBox(height: 16),
                ],

                /// Decisions
                if (isRequestGone)
                  FilledButton(
                    onPressed: () => Navigator.maybePop(context),
                    child: Text(l10n.close),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isBusy ? null : () => _submit(context, PaymentStatus.rejected),
                          child: pendingDecision == PaymentStatus.rejected
                              ? const _ButtonSpinner()
                              : Text(l10n.reject),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: isBusy ? null : () => _submit(context, PaymentStatus.approved),
                          child: pendingDecision == PaymentStatus.approved
                              ? const _ButtonSpinner()
                              : Text(l10n.approve),
                        ),
                      ),
                    ],
                  ),
                if (state case ApprovalAuthenticating() || ApprovalSubmitting()) ...[
                  const SizedBox(height: 12),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      switch (state) {
                        ApprovalSubmitting(decision: PaymentStatus.approved) =>
                          l10n.approvalApproving,
                        ApprovalSubmitting(decision: PaymentStatus.rejected) =>
                          l10n.approvalRejecting,
                        _ => l10n.approvalAuthenticating,
                      },
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MaskedRequestCard extends StatelessWidget {
  const _MaskedRequestCard({required this.request});

  final PaymentRequest request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          children: [
            _RequestRow(
              label: l10n.approvalTo,
              value: request.maskedRecipient,
              semanticsLabel: l10n.approvalRecipientHidden,
            ),
            const Divider(),
            _RequestRow(
              label: l10n.approvalAmount,
              value: maskedAmount(request.currency),
              semanticsLabel: l10n.approvalAmountHidden,
            ),
            const Divider(),
            _RequestRow(label: l10n.approvalReference, value: request.reference),
          ],
        ),
      ),
    );
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({required this.label, required this.value, this.semanticsLabel});

  final String label;
  final String value;

  /// Set for masked values, so screen readers don't read out a row of bullets.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMasked = semanticsLabel != null;

    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          if (isMasked) ...[
            Icon(Icons.lock_rounded, size: 14, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.titleSmall?.tabular,
            ),
          ),
        ],
      ),
    );

    return isMasked
        ? Semantics(label: '$label: $semanticsLabel', excludeSemantics: true, child: row)
        : MergeSemantics(child: row);
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.error});

  final ApprovalError error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final message = switch (error) {
      ApprovalError.authFailed => l10n.approvalErrorAuthFailed,
      ApprovalError.authLockedOut => l10n.approvalErrorAuthLockedOut,
      ApprovalError.authUnavailable => l10n.approvalErrorAuthUnavailable,
      ApprovalError.requestUnavailable => l10n.approvalErrorRequestUnavailable,
      ApprovalError.submitFailed => l10n.approvalErrorSubmitFailed,
    };

    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 18,
                color: theme.colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: 20,
      child: CircularProgressIndicator(strokeWidth: 2.4),
    );
  }
}
