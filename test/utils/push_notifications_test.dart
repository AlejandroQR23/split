import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:split/providers/push_provider.dart';
import 'package:split/utils/push_notifications.dart';

void main() {
  group('consumePendingNotificationRoute', () {
    test('consumes a pending route exactly once and clears it', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(pendingNotificationRouteProvider.notifier).state =
          '/groups/group/abc';

      final visited = <String>[];
      consumePendingNotificationRoute(container, visited.add);
      consumePendingNotificationRoute(container, visited.add);

      expect(visited, ['/groups/group/abc']);
      expect(container.read(pendingNotificationRouteProvider), isNull);
    });

    test('does nothing when there is no pending route', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final visited = <String>[];
      consumePendingNotificationRoute(container, visited.add);

      expect(visited, isEmpty);
    });
  });

  group('extractNotificationRoute', () {
    test('extracts the home route for a monthly_reminder', () {
      expect(
        extractNotificationRoute({'type': 'monthly_reminder', 'route': '/'}),
        '/',
      );
    });

    test('extracts a group route for new_expense', () {
      expect(
        extractNotificationRoute({
          'type': 'new_expense',
          'route': '/groups/group/abc-123',
        }),
        '/groups/group/abc-123',
      );
    });

    test('extracts a group route for new_payment', () {
      expect(
        extractNotificationRoute({
          'type': 'new_payment',
          'route': '/groups/group/abc-123',
        }),
        '/groups/group/abc-123',
      );
    });

    test('rejects an unknown type', () {
      expect(
        extractNotificationRoute({'type': 'something_else', 'route': '/'}),
        isNull,
      );
    });

    test('rejects a missing route', () {
      expect(
        extractNotificationRoute({'type': 'new_expense'}),
        isNull,
      );
    });

    test('rejects a route outside the allowed shapes', () {
      expect(
        extractNotificationRoute({
          'type': 'new_expense',
          'route': '/sign-in',
        }),
        isNull,
      );
    });

    test('rejects an empty map', () {
      expect(extractNotificationRoute({}), isNull);
    });
  });
}
