import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:split/providers/push_provider.dart';

const _knownTypes = {'new_expense', 'new_payment', 'monthly_reminder'};

final _groupRoutePattern = RegExp(r'^/groups/group/[^/]+$');

/// Extracts the route to navigate to from a push's `data` payload, or
/// `null` if it isn't a recognized shape (see docs/notifications/overview.md).
String? extractNotificationRoute(Map<String, dynamic> data) {
  final type = data['type'];
  if (type is! String || !_knownTypes.contains(type)) return null;

  final route = data['route'];
  if (route is! String) return null;
  if (route == '/') return route;
  if (_groupRoutePattern.hasMatch(route)) return route;

  return null;
}

/// Listens for taps on a push (cold-start and warm), invoking [onRoute] with its route.
void listenForNotificationTaps(void Function(String route) onRoute) {
  void handleMessage(RemoteMessage message) {
    final route = extractNotificationRoute(message.data);
    if (route == null) return;

    onRoute(route);
  }

  FirebaseMessaging.instance
      .getInitialMessage()
      .then((message) {
        if (message != null) handleMessage(message);
      })
      .catchError((error) {
        debugPrint('[push-debug] getInitialMessage error: $error');
      });
  FirebaseMessaging.onMessageOpenedApp.listen(
    handleMessage,
    onError: (error) =>
        debugPrint('[push-debug] onMessageOpenedApp error: $error'),
  );
}

/// Consumes and clears a route stashed while signed out — a no-op if there isn't one.
void consumePendingNotificationRoute(
  ProviderContainer container,
  void Function(String route) onRoute,
) {
  final pending = container.read(pendingNotificationRouteProvider);
  if (pending == null) return;

  container.read(pendingNotificationRouteProvider.notifier).state = null;
  onRoute(pending);
}
