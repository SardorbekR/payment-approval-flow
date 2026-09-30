import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/l10n/app_localizations.dart';

/// On a wide browser window, shows the app in a phone frame next to a short guide. On phones and in
/// the native apps it adds nothing
class DemoFrame extends StatelessWidget {
  const DemoFrame({required this.enabled, required this.child, super.key});

  final bool enabled;
  final Widget child;

  static const _screen = Size(390, 844);
  static const _bezel = 12.0;
  static const _guideWidth = 340.0;
  static const _gap = 64.0;
  static const _margin = 32.0;

  /// Smaller windows, like tablets or phones in landscape, show the app without a frame
  static const _minWindow = Size(900, 640);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final window = media.size;
    if (!enabled || window.width < _minWindow.width || window.height < _minWindow.height) {
      return child;
    }

    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return ColoredBox(
      color: isLight ? const Color(0xFFE9EBEF) : const Color(0xFF05080C),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(_margin),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _guideWidth),
                child: const _Guide(),
              ),
              const SizedBox(width: _gap),
              ConstrainedBox(
                // The phone takes the room the guide leaves, scaled down to fit but never up
                constraints: BoxConstraints(
                  maxWidth: window.width - _margin * 2 - _guideWidth - _gap,
                  maxHeight: window.height - _margin * 2,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _Phone(
                    screen: _screen,
                    bezel: _bezel,
                    // The app lays out for the phone screen, with the status bar and home indicator
                    // areas of a real device
                    child: MediaQuery(
                      data: media.copyWith(
                        size: _screen,
                        padding: const EdgeInsets.only(top: 47, bottom: 34),
                        viewPadding: const EdgeInsets.only(top: 47, bottom: 34),
                        viewInsets: EdgeInsets.zero,
                      ),
                      child: child,
                    ),
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

class _Phone extends StatelessWidget {
  const _Phone({required this.screen, required this.bezel, required this.child});

  final Size screen;
  final double bezel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    const rim = 3.0;

    return Container(
      // The rim is part of the bezel, so the phone keeps its size
      padding: EdgeInsets.all(bezel - rim),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F14),
        // A metal edge, so the phone stands out on a dark page too
        border: Border.all(
          color: isLight ? const Color(0xFF2E343C) : const Color(0xFF3F4652),
          width: rim,
        ),
        borderRadius: BorderRadius.circular(56),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 48, offset: Offset(0, 24)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(44),
        child: SizedBox.fromSize(size: screen, child: child),
      ),
    );
  }
}

class _Guide extends StatelessWidget {
  const _Guide();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final steps = [l10n.demoStepReceive, l10n.demoStepDecide, l10n.demoStepObserve];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.demoTitle,
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.demoSubtitle,
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
        for (final (index, step) in steps.indexed) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: theme.colorScheme.secondary,
                child: Text(
                  '${index + 1}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(step, style: theme.textTheme.bodyMedium)),
            ],
          ),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 8),
        Text(l10n.demoSessionNote, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
