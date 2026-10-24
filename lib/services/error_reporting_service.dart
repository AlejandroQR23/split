import 'package:sentry_flutter/sentry_flutter.dart';

abstract class ErrorReportingService {
  void setUser(String? userId);
  void captureException(Object error, StackTrace stackTrace);
}

class SentryErrorReportingService implements ErrorReportingService {
  @override
  void setUser(String? userId) {
    Sentry.configureScope(
      (scope) => scope.setUser(userId == null ? null : SentryUser(id: userId)),
    );
  }

  @override
  void captureException(Object error, StackTrace stackTrace) {
    Sentry.captureException(error, stackTrace: stackTrace);
  }
}
