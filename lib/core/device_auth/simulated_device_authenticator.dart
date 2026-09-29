import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/core/device_auth/device_authenticator.dart';
import 'package:payment_approval/l10n/app_localizations.dart';

/// Browsers can't reach Face ID or fingerprint sensors, so the web build shows
/// a clearly labeled dialog in place of the system prompt. It offers success,
/// cancel and failure, so every path of the approval flow can be tried.
class SimulatedDeviceAuthenticator implements DeviceAuthenticator {
  SimulatedDeviceAuthenticator({required GlobalKey<NavigatorState> navigatorKey})
    : _navigatorKey = navigatorKey;

  final GlobalKey<NavigatorState> _navigatorKey;

  @override
  Future<DeviceAuthResult> authenticate({required String reason}) async {
    final context = _navigatorKey.currentContext;
    if (context == null) return DeviceAuthResult.unavailable;

    final result = await showDialog<DeviceAuthResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SimulatedAuthDialog(reason: reason),
    );

    // The dialog can also close without an answer, for example through the browser's back button.
    return result ?? DeviceAuthResult.canceled;
  }
}

class SimulatedAuthDialog extends StatelessWidget {
  const SimulatedAuthDialog({required this.reason, super.key});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    const compact = Size(64, 40);

    return AlertDialog(
      icon: Icon(Icons.fingerprint_rounded, size: 44, color: theme.colorScheme.secondary),
      title: Text(l10n.simulatedAuthTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(reason, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l10n.simulatedAuthNotice, style: theme.textTheme.bodySmall)),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, DeviceAuthResult.failed),
          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
          child: Text(l10n.simulatedAuthFail),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, DeviceAuthResult.canceled),
          child: Text(l10n.simulatedAuthCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, DeviceAuthResult.success),
          style: FilledButton.styleFrom(minimumSize: compact),
          child: Text(l10n.simulatedAuthConfirm),
        ),
      ],
    );
  }
}
