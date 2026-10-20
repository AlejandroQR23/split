import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:split/models/notification_preferences.dart';
import 'package:split/providers/push_provider.dart';

const _defaultPreferences = NotificationPreferences(
  notifyNewExpense: true,
  notifyMonthlyReminder: true,
);

/// Signed-in member's push-notification preferences (see docs/notifications/overview.md).
class NotificationPreferencesNotifier
    extends AsyncNotifier<NotificationPreferences> {
  @override
  Future<NotificationPreferences> build() {
    final repository = ref.watch(deviceRepositoryProvider);
    if (repository == null) return Future.value(_defaultPreferences);

    return repository.fetchPreferences();
  }

  Future<void> updatePreference({
    bool? notifyNewExpense,
    bool? notifyMonthlyReminder,
  }) async {
    final previous = state;

    final keepAlive = ref.keepAlive();
    try {
      final repository = ref.read(deviceRepositoryProvider)!;
      final patch = <String, dynamic>{
        'notifyNewExpense': ?notifyNewExpense,
        'notifyMonthlyReminder': ?notifyMonthlyReminder,
      };
      state = AsyncData(await repository.updatePreferences(patch));
    } catch (error, stackTrace) {
      state = previous.hasValue ? previous : AsyncError(error, stackTrace);
      rethrow;
    } finally {
      keepAlive.close();
    }
  }
}

final notificationPreferencesProvider =
    AsyncNotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>(
      NotificationPreferencesNotifier.new,
    );
