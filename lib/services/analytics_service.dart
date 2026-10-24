import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

abstract class AnalyticsService {
  Future<void> init();
  void identify(String userId);
  void reset();
  void capture(String event, {Map<String, Object?>? properties});
}

class PostHogAnalyticsService implements AnalyticsService {
  bool _initialized = false;

  @override
  Future<void> init() async {
    final apiKey = dotenv.env['POSTHOG_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) return;

    final config = PostHogConfig(apiKey);
    final host = dotenv.env['POSTHOG_HOST'];
    if (host != null && host.isNotEmpty) {
      config.host = host;
    }

    await Posthog().setup(config);
    _initialized = true;
  }

  @override
  void identify(String userId) {
    if (!_initialized) return;
    Posthog().identify(userId: userId);
  }

  @override
  void reset() {
    if (!_initialized) return;
    Posthog().reset();
  }

  @override
  void capture(String event, {Map<String, Object?>? properties}) {
    if (!_initialized) return;
    Posthog().capture(
      eventName: event,
      properties: properties == null
          ? null
          : {
              for (final entry in properties.entries)
                if (entry.value != null) entry.key: entry.value as Object,
            },
    );
  }
}
