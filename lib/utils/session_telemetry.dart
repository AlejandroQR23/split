import 'package:split/services/analytics_service.dart';
import 'package:split/services/error_reporting_service.dart';

/// Called when a member becomes signed in, to tag subsequent error reports
/// and analytics events with their identity.
void identifyTelemetryUser({
  required ErrorReportingService errorReporting,
  required AnalyticsService analytics,
  required String memberId,
}) {
  errorReporting.setUser(memberId);
  analytics.identify(memberId);
}

/// Called on sign-out, to stop attributing error reports and analytics
/// events to the previous member.
void resetTelemetryOnSignOut({
  required ErrorReportingService errorReporting,
  required AnalyticsService analytics,
}) {
  errorReporting.setUser(null);
  analytics.reset();
}
