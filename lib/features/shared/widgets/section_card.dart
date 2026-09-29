import 'package:material_ui/material_ui.dart';

/// Rounded card that groups rows with dividers between them
class SectionCard extends StatelessWidget {
  const SectionCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0) const Divider(indent: 16, endIndent: 16),
            child,
          ],
        ],
      ),
    );
  }
}
