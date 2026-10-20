import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:split/models/notification_preferences.dart';
import 'package:split/providers/notification_preferences_provider.dart';
import 'package:split/providers/push_provider.dart';
import 'package:split/repositories/device_repository.dart';

class _FakeDeviceRepository implements DeviceRepository {
  _FakeDeviceRepository({this.updateError});

  final Object? updateError;
  Map<String, dynamic>? lastPatch;

  @override
  Future<Device> registerDevice({
    required String fcmToken,
    required String platform,
  }) => throw UnimplementedError();

  @override
  Future<Device> rotateToken({
    required String deviceId,
    required String fcmToken,
  }) => throw UnimplementedError();

  @override
  Future<void> unregister(String deviceId) => throw UnimplementedError();

  @override
  Future<NotificationPreferences> fetchPreferences() async {
    return const NotificationPreferences(
      notifyNewExpense: true,
      notifyMonthlyReminder: true,
    );
  }

  @override
  Future<NotificationPreferences> updatePreferences(
    Map<String, dynamic> patch,
  ) async {
    lastPatch = patch;
    if (updateError != null) throw updateError!;
    return const NotificationPreferences(
      notifyNewExpense: false,
      notifyMonthlyReminder: true,
    );
  }
}

void main() {
  test(
    'updatePreference optimistically updates then reconciles with the server response',
    () async {
      final fake = _FakeDeviceRepository();
      final container = ProviderContainer(
        overrides: [deviceRepositoryProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);

      await container.read(notificationPreferencesProvider.future);
      await container
          .read(notificationPreferencesProvider.notifier)
          .updatePreference(notifyNewExpense: false);

      final state = container.read(notificationPreferencesProvider);
      expect(state.value!.notifyNewExpense, false);
      expect(state.value!.notifyMonthlyReminder, true);
      expect(fake.lastPatch, {'notifyNewExpense': false});
    },
  );

  test(
    'updatePreference restores the previous value and rethrows on a repository error',
    () async {
      final fake = _FakeDeviceRepository(updateError: Exception('boom'));
      final container = ProviderContainer(
        overrides: [deviceRepositoryProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);

      final initial = await container.read(
        notificationPreferencesProvider.future,
      );

      await expectLater(
        () => container
            .read(notificationPreferencesProvider.notifier)
            .updatePreference(notifyNewExpense: false),
        throwsException,
      );

      final state = container.read(notificationPreferencesProvider);
      expect(state.value, initial);
    },
  );
}
