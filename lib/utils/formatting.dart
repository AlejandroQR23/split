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

String formatAmount(double amount) => '\$${amount.toStringAsFixed(2)}';

String formatDate(DateTime date) =>
    '${_monthAbbreviations[date.month - 1]} ${date.day}, ${date.year}';
