import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/features/debug_fab/fab_position.dart';

void main() {
  const screen = Size(390, 844);
  const safeArea = EdgeInsets.only(top: 47, bottom: 34);
  const size = 56.0;

  Offset clamp(Offset position, {Size on = screen, EdgeInsets padding = safeArea}) =>
      clampFabPosition(position, screen: on, safeArea: padding, size: size);

  group('clampFabPosition', () {
    test('leaves a position that is already on screen alone', () {
      expect(clamp(const Offset(100, 300)), const Offset(100, 300));
    });

    test('keeps the whole button on screen and clear of the system areas', () {
      expect(clamp(const Offset(500, 900)), const Offset(390 - 56, 844 - 34 - 56));
      expect(clamp(const Offset(-40, -40)), const Offset(0, 47));
    });

    test('pins the button to the top start corner on a screen smaller than it', () {
      expect(
        clamp(const Offset(10, 10), on: const Size(40, 40), padding: EdgeInsets.zero),
        Offset.zero,
      );
    });
  });

  group('defaultFabPosition', () {
    test('starts in the bottom end corner, above the navigation bar and snackbars', () {
      expect(
        defaultFabPosition(screen: screen, safeArea: safeArea, size: size),
        const Offset(390 - 56 - 16, 844 - 34 - 56 - 176),
      );
    });
  });
}
