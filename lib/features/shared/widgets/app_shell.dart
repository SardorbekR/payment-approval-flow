import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/features/debug_fab/fab_position.dart';
import 'package:payment_approval/l10n/app_localizations.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    // Tapping the tab that is already open returns it to its first page.
    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final inset = theme.snackBarTheme.insetPadding ?? EdgeInsets.zero;

    // Snackbars float above the debug button's resting spot, the way a Scaffold
    // lifts a snackbar above its own floating action button.
    return Theme(
      data: theme.copyWith(
        snackBarTheme: theme.snackBarTheme.copyWith(
          insetPadding: inset.copyWith(bottom: inset.bottom + fabMargin + fabSize),
        ),
      ),
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _goBranch,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: l10n.navHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined),
              selectedIcon: const Icon(Icons.receipt_long_rounded),
              label: l10n.navPayments,
            ),
          ],
        ),
      ),
    );
  }
}
