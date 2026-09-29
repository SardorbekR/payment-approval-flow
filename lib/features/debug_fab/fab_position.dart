import 'dart:math';

import 'package:material_ui/material_ui.dart';

/// Standard floating action button size
const fabSize = 56.0;

/// The gap the button keeps from the navigation bar and the screen edge
const fabMargin = 16.0;

/// Height of the Material navigation bar
const _navigationBarHeight = 80.0;

/// Where the button starts: the standard FAB spot above the navigation bar, at the bottom right
/// (bottom left in right to left languages). Tab screens show snackbars above this spot, so the
/// button never covers them
Offset defaultFabPosition({
  required Size screen,
  required EdgeInsets safeArea,
  required double size,
  required TextDirection textDirection,
}) {
  final x = switch (textDirection) {
    TextDirection.ltr => screen.width - safeArea.right - size - fabMargin,
    TextDirection.rtl => safeArea.left + fabMargin,
  };

  return Offset(x, screen.height - safeArea.bottom - _navigationBarHeight - fabMargin - size);
}

/// Keeps the button on screen and clear of the status bar, notch and home indicator
Offset clampFabPosition(
  Offset position, {
  required Size screen,
  required EdgeInsets safeArea,
  required double size,
}) {
  final minX = safeArea.left;
  final minY = safeArea.top;
  // On a screen smaller than the button, pin it to the top left corner
  final maxX = max(minX, screen.width - safeArea.right - size);
  final maxY = max(minY, screen.height - safeArea.bottom - size);

  return Offset(position.dx.clamp(minX, maxX), position.dy.clamp(minY, maxY));
}
