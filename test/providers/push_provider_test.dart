import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:split/models/notification_preferences.dart';
import 'package:split/providers/push_provider.dart';
import 'package:split/repositories/device_repository.dart';

class _FakeDeviceRepository implements DeviceRepository {
  _FakeDeviceRepository({this.unregisterError});

  final Object? unregisterError;
  int registerCalls = 0;
  String? unregisteredId;

  @override
  Future<Device> registerDevice({
    required String fcmToken,
    required String platform,
  }) async {
    registerCalls++;
    return Device(id: 'srv-1', platform: platform);
  }

  @override
  Future<Device> rotateToken({
    required String deviceId,
    required String fcmToken,
  }) => throw UnimplementedError();

  @override
  Future<void> unregister(String deviceId) async {
    unregisteredId = deviceId;
    if (unregisterError != null) throw unregisterError!;
  }

  @override
  Future<NotificationPreferences> fetchPreferences() =>
      throw UnimplementedError();

  @override
  Future<NotificationPreferences> updatePreferences(
    Map<String, dynamic> patch,
  ) => throw UnimplementedError();
}

void main() {
  group('ensureDeviceRegistered', () {
    test('on first resolve with no stored device id, registers and persists the returned id', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = _FakeDeviceRepository();

      await ensureDeviceRegistered(
        repository: repository,
        prefs: prefs,
        getToken: () async => 'tok-1',
        platform: 'android',
      );

      expect(repository.registerCalls, 1);
      expect(prefs.getString(deviceIdPrefsKey), 'srv-1');
    });

    test('on resolve with a stored device id, does not re-register', () async {
      SharedPreferences.setMockInitialValues({deviceIdPrefsKey: 'existing'});
      final prefs = await SharedPreferences.getInstance();
      final repository = _FakeDeviceRepository();

      await ensureDeviceRegistered(
        repository: repository,
        prefs: prefs,
        getToken: () async => 'tok-1',
        platform: 'android',
      );

      expect(repository.registerCalls, 0);
    });

    test('does nothing when there is no device repository (signed out)', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await ensureDeviceRegistered(
        repository: null,
        prefs: prefs,
        getToken: () async => 'tok-1',
        platform: 'android',
      );

      expect(prefs.getString(deviceIdPrefsKey), isNull);
    });

    test('does nothing when the token is unavailable', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = _FakeDeviceRepository();

      await ensureDeviceRegistered(
        repository: repository,
        prefs: prefs,
        getToken: () async => null,
        platform: 'android',
      );

      expect(repository.registerCalls, 0);
      expect(prefs.getString(deviceIdPrefsKey), isNull);
    });
  });

  group('unregisterStoredDevice', () {
    test('deletes the stored device and clears it, tolerating a repository error', () async {
      SharedPreferences.setMockInitialValues({deviceIdPrefsKey: 'srv-1'});
      final prefs = await SharedPreferences.getInstance();
      final repository = _FakeDeviceRepository(
        unregisterError: Exception('boom'),
      );

      await unregisterStoredDevice(repository: repository, prefs: prefs);

      expect(repository.unregisteredId, 'srv-1');
      expect(prefs.getString(deviceIdPrefsKey), isNull);
    });

    test('does nothing when nothing is stored', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = _FakeDeviceRepository();

      await unregisterStoredDevice(repository: repository, prefs: prefs);

      expect(repository.unregisteredId, isNull);
    });
  });
}
