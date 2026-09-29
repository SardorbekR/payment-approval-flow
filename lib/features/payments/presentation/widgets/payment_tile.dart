import 'package:clock/clock.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/core/formatting/date_formatter.dart';
import 'package:payment_approval/core/formatting/money_formatter.dart';
import 'package:payment_approval/core/theme/app_theme.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';
import 'package:payment_approval/features/shared/widgets/recipient_avatar.dart';
import 'package:payment_approval/features/shared/widgets/status_badge.dart';
import 'package:payment_approval/l10n/app_localizations.dart';

class PaymentTile extends StatelessWidget {
  const PaymentTile({
    required this.payment,
    required this.onTap,
    this.highlighted = false,
    super.key,
  });

  /// How long the highlight takes to fade
  static const highlightDuration = Duration(milliseconds: 2400);

  /// Narrowest row that fits the name beside the amount at normal text size. Larger text needs more
  static const _minRowWidth = 260.0;

  final Payment payment;
  final VoidCallback onTap;

  /// Briefly tints the row of a payment that was just decided
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isRejected = payment.status == PaymentStatus.rejected;

    final date = Text(
      formatPaymentDate(payment.decidedAt, now: clock.now(), l10n: l10n),
      style: theme.textTheme.bodySmall,
    );
    final amount = Text(
      formatMoney(payment.amount),
      style: theme.textTheme.titleMedium?.tabular.copyWith(
        color: isRejected ? theme.colorScheme.onSurfaceVariant : null,
      ),
    );
    final badge = StatusBadge(status: payment.status);

    final row = InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // With large text the amount moves under the name instead of squeezing it
            final stacked =
                constraints.maxWidth < _minRowWidth * MediaQuery.textScalerOf(context).scale(1);

            return Row(
              crossAxisAlignment: stacked ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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
                        maxLines: stacked ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      date,
                      if (stacked) ...[
                        const SizedBox(height: 8),
                        amount,
                        const SizedBox(height: 4),
                        badge,
                      ],
                    ],
                  ),
                ),
                if (!stacked) ...[
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [amount, const SizedBox(height: 4), badge],
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );

    return MergeSemantics(
      child: highlighted ? _FadingHighlight(child: row) : row,
    );
  }
}

/// Fades the tint out over a couple of seconds. It only animates while visible, so a payment
/// approved from another tab still gets noticed
class _FadingHighlight extends StatelessWidget {
  const _FadingHighlight({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tint = Theme.of(context).colorScheme.secondary;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.18, end: 0),
      duration: PaymentTile.highlightDuration,
      curve: Curves.easeInCubic,
      builder: (context, opacity, child) => Ink(
        color: tint.withValues(alpha: opacity),
        child: child,
      ),
      child: child,
    );
  }
}
