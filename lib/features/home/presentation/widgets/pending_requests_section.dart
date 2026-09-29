import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/core/theme/app_colors.dart';
import 'package:payment_approval/features/approval/presentation/approval_presenter.dart';
import 'package:payment_approval/features/payments/domain/models/payment_request.dart';
import 'package:payment_approval/features/shared/widgets/section_card.dart';
import 'package:payment_approval/features/shared/widgets/section_header.dart';
import 'package:payment_approval/l10n/app_localizations.dart';

/// Requests the user closed without deciding. Tapping one reopens its sheet, since a pending
/// request has no details screen
class PendingRequestsSection extends StatelessWidget {
  const PendingRequestsSection({required this.requests, super.key});

  final List<PaymentRequest> requests;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.pendingSectionTitle),
        SectionCard(
          children: [
            for (final request in requests)
              _PendingRequestTile(
                key: ValueKey(request.id),
                request: request,
                onTap: () => context.read<ApprovalPresenter>().review(request),
              ),
          ],
        ),
      ],
    );
  }
}

class _PendingRequestTile extends StatelessWidget {
  const _PendingRequestTile({required this.request, required this.onTap, super.key});

  final PaymentRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final colors = context.statusColors;

    return MergeSemantics(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 12, 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colors.pendingContainer,
                child: Icon(Icons.lock_outline_rounded, size: 20, color: colors.pending),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      label: l10n.approvalRecipientHidden,
                      excludeSemantics: true,
                      child: Text(
                        request.maskedRecipient,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.pendingRequestSubtitle(request.reference),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.reviewAction,
                style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.secondary),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.colorScheme.secondary),
            ],
          ),
        ),
      ),
    );
  }
}
