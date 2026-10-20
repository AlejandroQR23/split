import 'package:flutter/foundation.dart';

/// A member's per-member push-notification settings — whether they get a
/// push when a new expense/payment involves them, and whether they get the
/// monthly debt reminder. See `docs/notifications/overview.md`.
@immutable
class NotificationPreferences {
  const NotificationPreferences({
    required this.notifyNewExpense,
    required this.notifyMonthlyReminder,
  });

  final bool notifyNewExpense;
  final bool notifyMonthlyReminder;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      notifyNewExpense: json['notifyNewExpense'] as bool,
      notifyMonthlyReminder: json['notifyMonthlyReminder'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'notifyNewExpense': notifyNewExpense,
    'notifyMonthlyReminder': notifyMonthlyReminder,
  };

  NotificationPreferences copyWith({
    bool? notifyNewExpense,
    bool? notifyMonthlyReminder,
  }) {
    return NotificationPreferences(
      notifyNewExpense: notifyNewExpense ?? this.notifyNewExpense,
      notifyMonthlyReminder:
          notifyMonthlyReminder ?? this.notifyMonthlyReminder,
    );
  }
}
