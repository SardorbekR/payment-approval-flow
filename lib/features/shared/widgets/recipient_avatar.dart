import 'package:material_ui/material_ui.dart';

/// The color comes from the name, so a recipient always gets the same one
class RecipientAvatar extends StatelessWidget {
  const RecipientAvatar({required this.name, this.size = 40, super.key});

  final String name;
  final double size;

  static const _tints = [
    Color(0xFF4F5BD5),
    Color(0xFF0E9384),
    Color(0xFFDC6803),
    Color(0xFFC11574),
    Color(0xFF1570EF),
    Color(0xFF6938EF),
  ];

  @override
  Widget build(BuildContext context) {
    final tint = _tints[name.codeUnits.fold(0, (sum, unit) => sum + unit) % _tints.length];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? Color.lerp(tint, Colors.white, 0.45)! : tint;

    return ExcludeSemantics(
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: tint.withValues(alpha: isDark ? 0.24 : 0.14),
        child: Text(
          _initials(name),
          style: TextStyle(color: foreground, fontWeight: FontWeight.w700, fontSize: size * 0.36),
        ),
      ),
    );
  }

  static String _initials(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.characters.first.toUpperCase();

    return '${words.first.characters.first}${words.last.characters.first}'.toUpperCase();
  }
}
