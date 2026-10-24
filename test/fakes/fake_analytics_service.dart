import 'package:split/services/analytics_service.dart';

/// Shared `AnalyticsService` test double: records every `capture(...)` call
/// (event name + properties) and the last `identify`/`reset` call, so a test
/// can assert on whichever of those it cares about.
class FakeAnalyticsService implements AnalyticsService {
  final captured = <(String, Map<String, Object?>?)>[];
  String? identifiedId;
  bool resetCalled = false;

  @override
  Future<void> init() async {}

  @override
  void identify(String userId) => identifiedId = userId;

  @override
  void reset() => resetCalled = true;

  @override
  void capture(String event, {Map<String, Object?>? properties}) =>
      captured.add((event, properties));
}
