import 'package:clock/clock.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/core/formatting/date_formatter.dart';
import 'package:payment_approval/core/formatting/money_formatter.dart';
import 'package:payment_approval/core/theme/app_theme.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';
import 'package:payment_approval/features/shared/widgets/recipient_avatar.dart';
import 'package:payment_approval/features/shared/widgets/status_badge.dart';
import 'package:payment_approval/l10n/app_localizations.dart';

/// One payment in a list: who it's with, when, the amount and its status.
class PaymentTile extends StatelessWidget {
  const PaymentTile({
    required this.payment,
    required this.onTap,
    this.highlighted = false,
    super.key,
  });

  final Payment payment;
  final VoidCallback onTap;

  /// Briefly tints the row, for a payment that was just decided.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isRejected = payment.status == PaymentStatus.rejected;

    final row = InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
        child: Row(
          children: [
            RecipientAvatar(name: payment.recipientName),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.recipientName,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatPaymentDate(payment.decidedAt, now: clock.now(), l10n: l10n),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatMoney(payment.amount),
                  style: theme.textTheme.titleMedium?.tabular.copyWith(
                    color: isRejected ? theme.colorScheme.onSurfaceVariant : null,
                  ),
                ),
                const SizedBox(height: 4),
                StatusBadge(status: payment.status),
              ],
            ),
          ],
        ),
      ),
    );

    return MergeSemantics(
      child: highlighted ? _FadingHighlight(child: row) : row,
    );
  }
}

/// Fades a tint out over a couple of seconds. The animation only runs while the
/// row is visible, so a payment approved from another tab still gets noticed.
class _FadingHighlight extends StatelessWidget {
  const _FadingHighlight({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tint = Theme.of(context).colorScheme.secondary;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.18, end: 0),
      duration: const Duration(milliseconds: 2400),
      curve: Curves.easeInCubic,
      builder: (context, opacity, child) => Ink(
        color: tint.withValues(alpha: opacity),
        child: child,
      ),
      child: child,
    );
  }
}
