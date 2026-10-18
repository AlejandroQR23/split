import 'package:flutter/widgets.dart' show Color;

import 'package:split/theme/app_colors.dart';

const _monthAbbreviations = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

String formatAmount(double amount) {
  final sign = amount < 0 ? '-' : '';
  final parts = amount.abs().toStringAsFixed(2).split('.');
  final digits = parts[0];
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    if (i > 0 && remaining % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '$sign\$$buffer.${parts[1]}';
}

String formatDate(DateTime date) =>
    '${date.day} ${_monthAbbreviations[date.month - 1]} ${date.year}';

/// Fallback used when a server-sent label color fails to parse — one bad
/// label shouldn't crash the whole expense list.
const defaultLabelColor = AppColors.primary;

final _hexPattern = RegExp(r'^#[0-9A-Fa-f]{6}$');

/// Parses a `"#RRGGBB"` string into a [Color], or `null` if it doesn't
/// match that shape.
Color? colorFromHex(String? hex) {
  if (hex == null || !_hexPattern.hasMatch(hex)) return null;
  return Color(int.parse('FF${hex.substring(1)}', radix: 16));
}

/// Formats a [Color] as the `"#RRGGBB"` hex string the backend expects.
String hexFromColor(Color color) {
  final value = color.toARGB32() & 0xFFFFFF;
  return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
