import 'package:flutter_test/flutter_test.dart';
import 'package:split/services/error_reporting_service.dart';
import 'package:split/utils/session_telemetry.dart';

import '../fakes/fake_analytics_service.dart';

class _FakeErrorReporting implements ErrorReportingService {
  String? lastUserId;
  bool userIdSet = false;
  @override
  void setUser(String? userId) {
    lastUserId = userId;
    userIdSet = true;
  }

  @override
  void captureException(Object error, StackTrace stackTrace) {}
}

void main() {
  test(
    'identifyTelemetryUser sets the error-reporting user and identifies analytics',
    () {
      final errorReporting = _FakeErrorReporting();
      final analytics = FakeAnalyticsService();
      identifyTelemetryUser(
        errorReporting: errorReporting,
        analytics: analytics,
        memberId: 'mem_01',
      );
      expect(errorReporting.lastUserId, 'mem_01');
      expect(analytics.identifiedId, 'mem_01');
    },
  );

  test(
    'resetTelemetryOnSignOut clears the error-reporting user and resets analytics',
    () {
      final errorReporting = _FakeErrorReporting();
      final analytics = FakeAnalyticsService();
      resetTelemetryOnSignOut(
        errorReporting: errorReporting,
        analytics: analytics,
      );
      expect(errorReporting.userIdSet, isTrue);
      expect(errorReporting.lastUserId, isNull);
      expect(analytics.resetCalled, isTrue);
    },
  );
}
