import 'package:material_ui/material_ui.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Lines the title and a trailing text button up with the content of the card below
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 4, 0),
      child: ConstrainedBox(
        // Material subheader height, which fits a text button, so every header sits the same
        // distance from its card
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(title.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
