import 'dart:math';

import 'package:material_ui/material_ui.dart';

/// Where the button starts: the bottom end corner (bottom right, or bottom left
/// in right-to-left languages), above the navigation bar and the snackbars that
/// float over it, so it never covers their actions.
Offset defaultFabPosition({
  required Size screen,
  required EdgeInsets safeArea,
  required double size,
  required TextDirection textDirection,
}) {
  final x = switch (textDirection) {
    TextDirection.ltr => screen.width - safeArea.right - size - 16,
    TextDirection.rtl => safeArea.left + 16,
  };

  return Offset(x, screen.height - safeArea.bottom - size - 176);
}

/// Keeps the button fully on screen and clear of the status bar, notch and
/// home indicator. Applied after every drag and whenever the screen changes size.
Offset clampFabPosition(
  Offset position, {
  required Size screen,
  required EdgeInsets safeArea,
  required double size,
}) {
  final minX = safeArea.left;
  final minY = safeArea.top;
  // On a screen smaller than the button, keep it at the top-left corner.
  final maxX = max(minX, screen.width - safeArea.right - size);
  final maxY = max(minY, screen.height - safeArea.bottom - size);

  return Offset(position.dx.clamp(minX, maxX), position.dy.clamp(minY, maxY));
}
