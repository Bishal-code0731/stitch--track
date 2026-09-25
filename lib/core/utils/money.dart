import 'package:flutter/widgets.dart' show Locale;

import 'numerals.dart';

/// Currency symbols.
const String _symbolEn = 'Rs';
const String _symbolNe = 'रू';

/// Formats a rupee [amount] for display: `Rs 6,500` (en) / `रू ६,५००` (ne).
String formatMoney(num amount, Locale locale) {
  final negative = amount < 0;
  final totalPaisa = (amount.abs() * 100).round();
  final whole = totalPaisa ~/ 100;
  final paisa = totalPaisa % 100;

  final grouped = _groupThousands(whole.toString());
  final digits = paisa == 0
      ? grouped
      : '$grouped.${paisa.toString().padLeft(2, '0')}';

  final symbol = locale.languageCode == 'ne' ? _symbolNe : _symbolEn;
  final sign = negative ? '-' : '';
  return '$symbol $sign${numerals(digits, locale)}';
}

/// Inserts commas every three digits from the right (`1234567` → `1,234,567`).
String _groupThousands(String digits) {
  final buffer = StringBuffer();
  final length = digits.length;
  for (var i = 0; i < length; i++) {
    if (i > 0 && (length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
