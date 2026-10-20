import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:split/providers/auth_provider.dart';
import 'package:split/providers/current_member_provider.dart';
import 'package:split/providers/http_provider.dart';
import 'package:split/repositories/device_repository.dart';

/// `null` whenever there's no signed-in member — see docs/notifications/overview.md.
final deviceRepositoryProvider = Provider.autoDispose<DeviceRepository?>((
  ref,
) {
  final member = ref.watch(currentMemberProvider).value;
  if (member == null) return null;

  return DeviceRepositoryImpl(ref.watch(httpClientProvider));
});

/// A notification route that arrived while signed out, consumed once `main()` sees a signed-in member.
final pendingNotificationRouteProvider = StateProvider<String?>((ref) => null);

/// Where this device's own server-assigned [Device.id] is persisted.
@visibleForTesting
const deviceIdPrefsKey = 'push_device_id';

/// Registers this device once per member sign-in, if not already registered. See docs/notifications/overview.md.
Future<void> ensureDeviceRegistered({
  required DeviceRepository? repository,
  required SharedPreferences prefs,
  required Future<String?> Function() getToken,
  required String platform,
}) async {
  if (repository == null) return;
  if (prefs.getString(deviceIdPrefsKey) != null) return;

  final token = await getToken();
  if (token == null) return;

  final device = await repository.registerDevice(
    fcmToken: token,
    platform: platform,
  );
  await prefs.setString(deviceIdPrefsKey, device.id);
}

/// Deletes this device's stored registration, best-effort — never blocks sign-out.
Future<void> unregisterStoredDevice({
  required DeviceRepository? repository,
  required SharedPreferences prefs,
}) async {
  final deviceId = prefs.getString(deviceIdPrefsKey);
  if (deviceId == null) return;

  try {
    await repository?.unregister(deviceId);
  } catch (error) {
    debugPrint('[push-debug] unregister on sign-out failed: $error');
  }
  await prefs.remove(deviceIdPrefsKey);
}

/// Whether the OS has granted notification permission — drives the settings screen's disabled state.
final notificationPermissionStatusProvider =
    FutureProvider.autoDispose<AuthorizationStatus>((ref) async {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      return settings.authorizationStatus;
    });

/// Platform wiring around [ensureDeviceRegistered]: permission, APNs token on iOS, then registration and token-refresh rotation.
Future<void> registerDeviceForPush(DeviceRepository? repository) async {
  if (repository == null) return;

  final prefs = await SharedPreferences.getInstance();
  final messaging = FirebaseMessaging.instance;

  try {
    await ensureDeviceRegistered(
      repository: repository,
      prefs: prefs,
      platform: defaultTargetPlatform == TargetPlatform.iOS
          ? 'ios'
          : 'android',
      getToken: () async {
        final settings = await messaging.requestPermission();
        if (settings.authorizationStatus == AuthorizationStatus.denied) {
          return null;
        }

        if (defaultTargetPlatform == TargetPlatform.iOS) {
          for (var attempt = 0; attempt < 5; attempt++) {
            if (await messaging.getAPNSToken() != null) break;
            await Future.delayed(const Duration(seconds: 1));
          }
        }

        return messaging.getToken();
      },
    );
  } catch (error) {
    debugPrint('[push-debug] device registration failed: $error');
  }

  messaging.onTokenRefresh.listen((newToken) async {
    final deviceId = prefs.getString(deviceIdPrefsKey);
    if (deviceId == null) return;
    try {
      await repository.rotateToken(deviceId: deviceId, fcmToken: newToken);
    } catch (error) {
      debugPrint('[push-debug] token rotation failed: $error');
    }
  });
}

/// Unregisters this device, then signs out — in that order (see docs/notifications/overview.md).
Future<void> signOutAndUnregisterDevice(WidgetRef ref) async {
  final repository = ref.read(deviceRepositoryProvider);
  final prefs = await SharedPreferences.getInstance();
  await unregisterStoredDevice(repository: repository, prefs: prefs);
  await ref.read(authRepositoryProvider).signOut();
}
