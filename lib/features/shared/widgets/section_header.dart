import 'package:material_ui/material_ui.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Lines the title up with the content of the card below, and the text of a
      // trailing text button with the end of that content.
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 4, 0),
      child: ConstrainedBox(
        // Material's subheader height, which also fits a text button, so headers
        // with and without one sit the same distance from their cards.
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
