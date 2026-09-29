import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/features/payments/presentation/bloc/payments_bloc.dart';
import 'package:payment_approval/features/shared/widgets/message_view.dart';
import 'package:payment_approval/l10n/app_localizations.dart';

class PaymentsErrorView extends StatelessWidget {
  const PaymentsErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MessageView(
      icon: Icons.cloud_off_rounded,
      title: l10n.loadFailedTitle,
      message: l10n.loadFailedMessage,
      actionLabel: l10n.retry,
      onAction: () => context.read<PaymentsBloc>().add(const LoadPayments()),
    );
  }
}
