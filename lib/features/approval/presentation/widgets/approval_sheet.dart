import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/core/formatting/money_formatter.dart';
import 'package:payment_approval/core/theme/app_theme.dart';
import 'package:payment_approval/features/approval/presentation/bloc/approval_bloc.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';
import 'package:payment_approval/features/payments/domain/models/payment_request.dart';
import 'package:payment_approval/features/shared/widgets/labeled_value.dart';
import 'package:payment_approval/l10n/app_localizations.dart';

/// Asks the user to approve or reject a request without showing who it pays or how much. Closes
/// with the decided [Payment]
class ApprovalSheet extends StatelessWidget {
  const ApprovalSheet({required this.request, super.key});

  final PaymentRequest request;

  void _submit(BuildContext context, PaymentStatus decision) {
    final l10n = AppLocalizations.of(context);
    final reason = switch (decision) {
      PaymentStatus.approved => l10n.authReasonApprove(request.reference),
      PaymentStatus.rejected => l10n.authReasonReject(request.reference),
    };

    context.read<ApprovalBloc>().add(SubmitDecision(decision, authReason: reason));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<ApprovalBloc, ApprovalState>(
      listenWhen: (previous, current) => current is ApprovalSuccess,
      listener: (context, state) => Navigator.of(context).pop((state as ApprovalSuccess).payment),
      builder: (context, state) {
        final isBusy = state.isBusy;
        final isRequestGone =
            state is ApprovalError && state.reason == ApprovalErrorReason.requestUnavailable;
        final pendingDecision = switch (state) {
          ApprovalAuthenticating(:final decision) ||
          ApprovalSubmitting(:final decision) => decision,
          _ => null,
        };
        final progress = switch (state) {
          ApprovalAuthenticating() => l10n.approvalAuthenticating,
          ApprovalSubmitting(decision: PaymentStatus.approved) => l10n.approvalApproving,
          ApprovalSubmitting(decision: PaymentStatus.rejected) => l10n.approvalRejecting,
          _ => null,
        };

        return PopScope(
          // Closing mid-decision would hide whether the decision went through
          canPop: !isBusy,
          // Keeps the buttons above the home indicator, which the sheet's own safe area leaves out
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
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

                  _AnimatedSlot(
                    child: state is ApprovalError
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _ErrorMessage(reason: state.reason),
                          )
                        : null,
                  ),

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
                            onPressed: isBusy
                                ? null
                                : () => _submit(context, PaymentStatus.rejected),
                            child: pendingDecision == PaymentStatus.rejected
                                ? _ButtonSpinner(label: l10n.reject)
                                : Text(l10n.reject),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: isBusy
                                ? null
                                : () => _submit(context, PaymentStatus.approved),
                            child: pendingDecision == PaymentStatus.approved
                                ? _ButtonSpinner(label: l10n.approve)
                                : Text(l10n.approve),
                          ),
                        ),
                      ],
                    ),
                  _AnimatedSlot(
                    child: progress == null
                        ? null
                        : Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Semantics(
                              liveRegion: true,
                              child: Text(
                                progress,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
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

  /// Set for masked values, so screen readers don't read out a row of bullets
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMasked = semanticsLabel != null;

    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: LabeledValue(
        label: label,
        value: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMasked) ...[
              Icon(Icons.lock_rounded, size: 14, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
            ],
            Flexible(child: Text(value, style: theme.textTheme.titleSmall?.tabular)),
          ],
        ),
      ),
    );

    return isMasked
        ? Semantics(label: '$label: $semanticsLabel', excludeSemantics: true, child: row)
        : MergeSemantics(child: row);
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.reason});

  final ApprovalErrorReason reason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final message = switch (reason) {
      ApprovalErrorReason.authFailed => l10n.approvalErrorAuthFailed,
      ApprovalErrorReason.authLockedOut => l10n.approvalErrorAuthLockedOut,
      ApprovalErrorReason.authUnavailable => l10n.approvalErrorAuthUnavailable,
      ApprovalErrorReason.requestUnavailable => l10n.approvalErrorRequestUnavailable,
      ApprovalErrorReason.submitFailed => l10n.approvalErrorSubmitFailed,
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

/// Animates its height, so the sheet doesn't jump when a message appears
class _AnimatedSlot extends StatelessWidget {
  const _AnimatedSlot({required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: child ?? const SizedBox.shrink(),
    );
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner({required this.label});

  /// Keeps the button named for screen readers while the spinner replaces its text
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 20,
      child: CircularProgressIndicator(strokeWidth: 2.4, semanticsLabel: label),
    );
  }
}
