import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:split/services/analytics_service.dart';

void main() {
  test('capture is a no-op when POSTHOG_API_KEY is not configured', () async {
    // no POSTHOG_API_KEY
    dotenv.loadFromString(envString: '', isOptional: true);
    final service = PostHogAnalyticsService();
    await service.init();

    expect(() => service.capture('x'), returnsNormally);
  });
}
