import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/models/notification_preferences.dart';
import 'package:split/providers/push_provider.dart';
import 'package:split/repositories/device_repository.dart';
import 'package:split/screens/profile/preferences_screen.dart';

class _FakeDeviceRepository implements DeviceRepository {
  _FakeDeviceRepository({
    this.initial = const NotificationPreferences(
      notifyNewExpense: true,
      notifyMonthlyReminder: true,
    ),
    this.fetchError,
    this.updateError,
  });

  final NotificationPreferences initial;
  final Object? fetchError;
  final Object? updateError;
  int updateCalls = 0;

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
    if (fetchError != null) throw fetchError!;
    return initial;
  }

  @override
  Future<NotificationPreferences> updatePreferences(
    Map<String, dynamic> patch,
  ) async {
    updateCalls++;
    if (updateError != null) throw updateError!;
    return initial.copyWith(
      notifyNewExpense: patch['notifyNewExpense'] as bool?,
      notifyMonthlyReminder: patch['notifyMonthlyReminder'] as bool?,
    );
  }
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required DeviceRepository repository,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        notificationPermissionStatusProvider.overrideWith(
          (ref) async => AuthorizationStatus.authorized,
        ),
        deviceRepositoryProvider.overrideWithValue(repository),
      ],
      child: ShadApp.router(
        routerConfig: GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const PreferencesScreen(),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows both switches reflecting loaded preferences', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      repository: _FakeDeviceRepository(
        initial: const NotificationPreferences(
          notifyNewExpense: false,
          notifyMonthlyReminder: true,
        ),
      ),
    );

    final switches = tester.widgetList<ShadSwitch>(find.byType(ShadSwitch));
    expect(switches.map((s) => s.value).toList(), [false, true]);
  });

  testWidgets('shows AsyncErrorText when preferences fail to load', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      repository: _FakeDeviceRepository(fetchError: Exception('down')),
    );

    expect(find.textContaining('Error'), findsOneWidget);
  });

  testWidgets(
    'toggling a switch calls updatePreference and reverts with a destructive toast on failure',
    (tester) async {
      final repository = _FakeDeviceRepository(
        updateError: Exception('boom'),
      );
      await _pumpScreen(tester, repository: repository);

      await tester.tap(find.byType(ShadSwitch).first);
      await tester.pumpAndSettle();

      expect(repository.updateCalls, 1);
      final switches = tester.widgetList<ShadSwitch>(find.byType(ShadSwitch));
      expect(switches.first.value, true); // reverted
      expect(find.byType(ShadToast), findsOneWidget);
    },
  );
}
