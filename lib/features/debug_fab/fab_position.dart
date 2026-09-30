import 'dart:math';

import 'package:material_ui/material_ui.dart';

const fabSize = 56.0;
const fabMargin = 16.0;
const _navigationBarHeight = 80.0;

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
