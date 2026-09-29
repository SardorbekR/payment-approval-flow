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
    Rect startingRect(TextDirection textDirection) =>
        defaultFabPosition(
          screen: screen,
          safeArea: safeArea,
          size: size,
          textDirection: textDirection,
        ) &
        const Size.square(size);

    test('starts at the end side for the reading direction', () {
      expect(startingRect(TextDirection.ltr).right, greaterThan(screen.width - 32));
      expect(startingRect(TextDirection.rtl).left, lessThan(32));
    });

    test('starts just above the navigation bar, where a floating action button goes', () {
      // The navigation bar (80) and the standard gap (16).
      expect(startingRect(TextDirection.ltr).bottom, 844 - 34 - 80 - 16);
    });

    test('starts fully on screen', () {
      final visible = Rect.fromLTRB(0, 47, screen.width, screen.height - 34);

      for (final direction in TextDirection.values) {
        final rect = startingRect(direction);
        expect(visible.contains(rect.topLeft) && visible.contains(rect.bottomRight), isTrue);
      }
    });
  });
}
