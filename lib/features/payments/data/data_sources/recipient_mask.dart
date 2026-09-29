import 'package:characters/characters.dart';

/// Always four bullets, so the mask never reveals how long the name is.
const _hiddenPart = '••••';

/// Masks a recipient name the way the server does before sending a request:
/// the first letter, four bullets, then the initial of the last word.
/// "Ahmed Khalil" becomes "A•••• K.".
///
/// Works on grapheme clusters, so accented letters written with combining marks
/// and non-Latin scripts keep their first character intact.
String maskRecipientName(String fullName) {
  final words = fullName.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
  if (words.isEmpty) return _hiddenPart;

  final firstLetter = words.first.characters.first;
  if (words.length == 1) return '$firstLetter$_hiddenPart';

  return '$firstLetter$_hiddenPart ${words.last.characters.first}.';
}
