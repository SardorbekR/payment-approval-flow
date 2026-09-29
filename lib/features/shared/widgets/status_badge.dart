import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/core/theme/app_colors.dart';
import 'package:payment_approval/features/payments/domain/models/payment.dart';
import 'package:payment_approval/l10n/app_localizations.dart';

/// A small pill with an icon and a label, so the status never relies on color alone.
class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.status, super.key});

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.statusColors;
    final l10n = AppLocalizations.of(context);
    final (label, icon, foreground, background) = switch (status) {
      PaymentStatus.approved => (
        l10n.statusApproved,
        Icons.check_rounded,
        colors.approved,
        colors.approvedContainer,
      ),
      PaymentStatus.rejected => (
        l10n.statusRejected,
        Icons.close_rounded,
        colors.rejected,
        colors.rejectedContainer,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(6, 3, 9, 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}
