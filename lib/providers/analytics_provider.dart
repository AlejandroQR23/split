import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split/services/analytics_service.dart';

final analyticsServiceProvider = Provider<AnalyticsService>(
  (ref) => PostHogAnalyticsService(),
);
