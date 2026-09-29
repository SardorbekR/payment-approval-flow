import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/core/theme/app_colors.dart';

class AppTheme {
  const AppTheme();

  static const fontFamily = 'Inter';

  static const _accent = Color(0xFF4F5BD5);

  ThemeData light() => _build(Brightness.light);

  ThemeData dark() => _build(Brightness.dark);

  ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final ink = isLight ? const Color(0xFF111827) : const Color(0xFFF2F4F7);
    final background = isLight ? const Color(0xFFF4F5F7) : const Color(0xFF0D1117);

    final colorScheme = ColorScheme.fromSeed(seedColor: _accent, brightness: brightness).copyWith(
      primary: ink,
      onPrimary: isLight ? Colors.white : const Color(0xFF111827),
      secondary: isLight ? _accent : const Color(0xFFAAB2FF),
      surface: isLight ? Colors.white : const Color(0xFF161B22),
      onSurface: ink,
      onSurfaceVariant: isLight ? const Color(0xFF5B6573) : const Color(0xFF9AA4B2),
      outline: isLight ? const Color(0xFFCDD2D9) : const Color(0xFF3A4350),
      outlineVariant: isLight ? const Color(0xFFE6E8EC) : const Color(0xFF262D37),
    );
    final textTheme = _textTheme(ThemeData(brightness: brightness).textTheme, colorScheme);
    final roundedShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: background,
      extensions: [if (isLight) StatusColors.light else StatusColors.dark],
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.secondaryContainer,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant, thickness: 1, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: roundedShape,
          textStyle: textTheme.titleSmall,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: roundedShape,
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outline),
          textStyle: textTheme.titleSmall,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.secondary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: roundedShape,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      ),
    );
  }

  TextTheme _textTheme(TextTheme base, ColorScheme colorScheme) {
    final themed = base.apply(
      fontFamily: fontFamily,
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return themed.copyWith(
      displaySmall: themed.displaySmall?.copyWith(
        fontSize: 34,
        height: 1.15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
      ),
      headlineSmall: themed.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleLarge: themed.titleLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3),
      titleMedium: themed.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: themed.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodySmall: themed.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
      labelLarge: themed.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      labelMedium: themed.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      labelSmall: themed.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

extension TabularFigures on TextStyle {
  /// Digits of equal width, so amounts line up and don't shift as they change.
  TextStyle get tabular => copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
}
