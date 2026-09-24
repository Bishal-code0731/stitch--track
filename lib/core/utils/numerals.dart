import 'package:flutter/widgets.dart' show Locale;

/// Devanagari digits ०–९ indexed by their ASCII value (0–9).
const List<String> _devanagariDigits = [
  '०',
  '१',
  '२',
  '३',
  '४',
  '५',
  '६',
  '७',
  '८',
  '९',
];

String numerals(Object value, Locale locale) {
  final input = value.toString();
  if (locale.languageCode != 'ne') return input;

  final buffer = StringBuffer();
  for (final unit in input.codeUnits) {
    if (unit >= 0x30 && unit <= 0x39) {
      buffer.write(_devanagariDigits[unit - 0x30]);
    } else {
      buffer.writeCharCode(unit);
    }
  }
  return buffer.toString();
}
