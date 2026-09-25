import 'package:flutter/widgets.dart' show Locale;

import 'numerals.dart';

const List<String> _enMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const List<String> _neMonths = [
  'जन',
  'फेब',
  'मार्च',
  'अप्रिल',
  'मे',
  'जुन',
  'जुलाई',
  'अगस्ट',
  'सेप्ट',
  'अक्टो',
  'नोभे',
  'डिसे',
];

/// Formats a date as `2 Jun 2026` / `२ जुन २०२६` (day, short month, year) in the given [locale].
String formatShortDate(DateTime date, Locale locale) {
  final ne = locale.languageCode == 'ne';
  final month = (ne ? _neMonths : _enMonths)[date.month - 1];
  return '${numerals(date.day, locale)} $month ${numerals(date.year, locale)}';
}
