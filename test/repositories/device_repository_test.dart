import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:split/repositories/device_repository.dart';
import 'package:split/utils/network_exception.dart';

void main() {
  group('registerDevice', () {
    test('POSTs to devices and parses the 201 device', () async {
      final inner = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, 'devices');
        expect(jsonDecode(request.body), {
          'fcmToken': 'tok-1',
          'platform': 'android',
        });
        return http.Response(
          jsonEncode({
            'id': 'dev_01h',
            'platform': 'android',
            'createdAt': '2026-10-18T00:00:00.000Z',
            'lastSeenAt': '2026-10-18T00:00:00.000Z',
          }),
          201,
        );
      });
      final repository = DeviceRepositoryImpl(inner);

      final device = await repository.registerDevice(
        fcmToken: 'tok-1',
        platform: 'android',
      );

      expect(device.id, 'dev_01h');
      expect(device.platform, 'android');
    });

    test('surfaces a non-2xx error envelope instead of a raw decode crash', () async {
      final inner = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'error': {'code': 'validation_error', 'message': 'Bad token'},
          }),
          422,
        );
      });
      final repository = DeviceRepositoryImpl(inner);

      await expectLater(
        () => repository.registerDevice(fcmToken: '', platform: 'android'),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('rotateToken', () {
    test('PATCHes the given device id with the new token', () async {
      final inner = MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.path, 'devices/dev_01h');
        expect(jsonDecode(request.body), {'fcmToken': 'tok-2'});
        return http.Response(
          jsonEncode({
            'id': 'dev_01h',
            'platform': 'android',
            'createdAt': '2026-10-18T00:00:00.000Z',
            'lastSeenAt': '2026-10-18T00:00:00.000Z',
          }),
          200,
        );
      });
      final repository = DeviceRepositoryImpl(inner);

      final device = await repository.rotateToken(
        deviceId: 'dev_01h',
        fcmToken: 'tok-2',
      );

      expect(device.id, 'dev_01h');
    });
  });

  group('unregister', () {
    test('DELETEs the given device id', () async {
      final inner = MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.url.path, 'devices/dev_01h');
        return http.Response('', 204);
      });
      final repository = DeviceRepositoryImpl(inner);

      await repository.unregister('dev_01h');
    });

    test('tolerates a 404 as already-gone', () async {
      final inner = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'error': {'code': 'not_found', 'message': 'Gone'},
          }),
          404,
        );
      });
      final repository = DeviceRepositoryImpl(inner);

      await repository.unregister('dev_01h');
    });
  });

  group('fetchPreferences', () {
    test('GETs and parses the preferences', () async {
      final inner = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, 'members/me/notification-preferences');
        return http.Response(
          jsonEncode({
            'notifyNewExpense': true,
            'notifyMonthlyReminder': false,
          }),
          200,
        );
      });
      final repository = DeviceRepositoryImpl(inner);

      final prefs = await repository.fetchPreferences();

      expect(prefs.notifyNewExpense, true);
      expect(prefs.notifyMonthlyReminder, false);
    });
  });

  group('updatePreferences', () {
    test('PATCHes a partial body and returns the full result', () async {
      final inner = MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.path, 'members/me/notification-preferences');
        expect(jsonDecode(request.body), {'notifyNewExpense': false});
        return http.Response(
          jsonEncode({
            'notifyNewExpense': false,
            'notifyMonthlyReminder': true,
          }),
          200,
        );
      });
      final repository = DeviceRepositoryImpl(inner);

      final prefs = await repository.updatePreferences({
        'notifyNewExpense': false,
      });

      expect(prefs.notifyNewExpense, false);
      expect(prefs.notifyMonthlyReminder, true);
    });
  });
}
