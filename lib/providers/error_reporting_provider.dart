import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split/services/error_reporting_service.dart';

final errorReportingServiceProvider = Provider<ErrorReportingService>(
  (ref) => SentryErrorReportingService(),
);
