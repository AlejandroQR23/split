const _monthAbbreviations = [
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
    '${_monthAbbreviations[date.month - 1]} ${date.day}, ${date.year}';
