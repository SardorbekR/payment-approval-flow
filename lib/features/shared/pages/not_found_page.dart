import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/features/shared/widgets/message_view.dart';
import 'package:payment_approval/l10n/app_localizations.dart';
import 'package:payment_approval/router.dart';

/// Shown for unknown URLs on the web
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: MessageView(
        icon: Icons.link_off_rounded,
        title: l10n.pageNotFoundTitle,
        message: l10n.pageNotFoundMessage,
        actionLabel: l10n.goToHome,
        onAction: () => context.goNamed(Routes.home.name),
      ),
    );
  }
}
