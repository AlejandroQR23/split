import 'package:flutter_test/flutter_test.dart';
import 'package:split/models/notification_preferences.dart';

void main() {
  group('NotificationPreferences', () {
    test('round-trips through JSON', () {
      final prefs = NotificationPreferences.fromJson({
        'notifyNewExpense': false,
        'notifyMonthlyReminder': true,
      });

      expect(prefs.notifyNewExpense, false);
      expect(prefs.notifyMonthlyReminder, true);
      expect(prefs.toJson(), {
        'notifyNewExpense': false,
        'notifyMonthlyReminder': true,
      });
    });

    test('copyWith overrides only the given field', () {
      final prefs = NotificationPreferences(
        notifyNewExpense: false,
        notifyMonthlyReminder: true,
      );

      final updated = prefs.copyWith(notifyNewExpense: true);

      expect(updated.notifyNewExpense, true);
      expect(updated.notifyMonthlyReminder, true);
    });
  });
}
