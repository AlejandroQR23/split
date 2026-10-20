import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:split/models/notification_preferences.dart';
import 'package:split/utils/network_exception.dart';

class Device {
  const Device({required this.id, required this.platform});

  final String id;
  final String platform;

  factory Device.fromJson(Map<String, dynamic> json) => Device(
    id: json['id'] as String,
    platform: json['platform'] as String,
  );
}

abstract class DeviceRepository {
  Future<Device> registerDevice({
    required String fcmToken,
    required String platform,
  });
  Future<Device> rotateToken({
    required String deviceId,
    required String fcmToken,
  });
  Future<void> unregister(String deviceId);
  Future<NotificationPreferences> fetchPreferences();
  Future<NotificationPreferences> updatePreferences(
    Map<String, dynamic> patch,
  );
}

/// Unlike the other repositories, explicitly checks [http.Response.statusCode] before decoding (see todo.md).
class DeviceRepositoryImpl implements DeviceRepository {
  final http.Client _client;

  DeviceRepositoryImpl(this._client);

  void _checkStatusCode(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    if (response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);
      final errorJson = decoded is Map<String, dynamic>
          ? decoded['error']
          : null;
      if (errorJson is Map<String, dynamic>) {
        throw NetworkException(
          APIError.fromJson(errorJson),
          response.statusCode,
        );
      }
    }

    throw NetworkException(
      APIError(message: 'Ocurrió un error inesperado', code: 'unexpected_error'),
      response.statusCode,
    );
  }

  @override
  Future<Device> registerDevice({
    required String fcmToken,
    required String platform,
  }) async {
    final response = await _client.post(
      Uri.parse('devices'),
      body: jsonEncode({'fcmToken': fcmToken, 'platform': platform}),
    );

    _checkStatusCode(response);

    return Device.fromJson(jsonDecode(response.body));
  }

  @override
  Future<Device> rotateToken({
    required String deviceId,
    required String fcmToken,
  }) async {
    final response = await _client.patch(
      Uri.parse('devices/$deviceId'),
      body: jsonEncode({'fcmToken': fcmToken}),
    );

    _checkStatusCode(response);

    return Device.fromJson(jsonDecode(response.body));
  }

  @override
  Future<void> unregister(String deviceId) async {
    final response = await _client.delete(Uri.parse('devices/$deviceId'));

    // A 404 means it's already gone — sign-out should never fail over this.
    if (response.statusCode == 404) return;

    _checkStatusCode(response);
  }

  @override
  Future<NotificationPreferences> fetchPreferences() async {
    final response = await _client.get(
      Uri.parse('members/me/notification-preferences'),
    );

    _checkStatusCode(response);

    return NotificationPreferences.fromJson(jsonDecode(response.body));
  }

  @override
  Future<NotificationPreferences> updatePreferences(
    Map<String, dynamic> patch,
  ) async {
    final response = await _client.patch(
      Uri.parse('members/me/notification-preferences'),
      body: jsonEncode(patch),
    );

    _checkStatusCode(response);

    return NotificationPreferences.fromJson(jsonDecode(response.body));
  }
}
