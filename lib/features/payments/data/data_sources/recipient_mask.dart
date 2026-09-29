import 'package:characters/characters.dart';

/// Always four bullets, so the mask never reveals how long the name is
const _hiddenPart = '••••';

/// Masks a name the way the server does: first letter, four bullets and the last word's initial.
/// "Ahmed Khalil" becomes "A•••• K."
///
/// Uses grapheme clusters, so accented and non-Latin letters stay whole
String maskRecipientName(String fullName) {
  final words = fullName.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
  if (words.isEmpty) return _hiddenPart;

  final firstLetter = words.first.characters.first;
  if (words.length == 1) return '$firstLetter$_hiddenPart';

  return '$firstLetter$_hiddenPart ${words.last.characters.first}.';
}
