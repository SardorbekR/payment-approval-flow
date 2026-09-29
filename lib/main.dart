import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/l10n/app_localizations.dart';

void main() => runApp(const _ScaffoldCheckApp());

class _ScaffoldCheckApp extends StatelessWidget {
  const _ScaffoldCheckApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(fontFamily: 'Inter'),
      home: Builder(
        builder: (context) =>
            Scaffold(body: Center(child: Text(AppLocalizations.of(context).appTitle))),
      ),
    );
  }
}
