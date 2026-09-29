import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/core/formatting/money_formatter.dart';
import 'package:payment_approval/core/theme/app_theme.dart';
import 'package:payment_approval/features/payments/domain/models/monthly_summary.dart';
import 'package:payment_approval/l10n/app_localizations.dart';

class MonthlySummaryCard extends StatelessWidget {
  const MonthlySummaryCard({required this.summary, super.key});

  final MonthlySummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final onCard = theme.colorScheme.onPrimary;
    final muted = onCard.withValues(alpha: 0.72);

    return MergeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.summaryLabel.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(color: muted),
              ),
              const SizedBox(height: 10),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  formatMoney(summary.total),
                  style: theme.textTheme.displaySmall?.tabular.copyWith(color: onCard),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.summaryApprovedCount(summary.approvedCount),
                style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              ),
              if (summary.rejectedCount > 0) ...[
                const SizedBox(height: 16),
                Divider(color: onCard.withValues(alpha: 0.16)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: muted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.summaryRejectedNote(summary.rejectedCount),
                        style: theme.textTheme.bodySmall?.copyWith(color: muted),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
