import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:split/utils/go_router_refresh_stream.dart';

void main() {
  test('notifies listeners each time the stream emits', () async {
    final controller = StreamController<int>();
    final refreshStream = GoRouterRefreshStream(controller.stream);
    var notifyCount = 0;
    refreshStream.addListener(() => notifyCount++);

    controller
      ..add(1)
      ..add(2);
    await Future<void>.delayed(Duration.zero);

    expect(notifyCount, 2);

    await controller.close();
    refreshStream.dispose();
  });

  test('notifies listeners when the stream emits an error', () async {
    final controller = StreamController<int>();
    final refreshStream = GoRouterRefreshStream(controller.stream);
    var notifyCount = 0;
    refreshStream.addListener(() => notifyCount++);

    controller.addError(Exception('stream error'));
    await Future<void>.delayed(Duration.zero);

    expect(notifyCount, 1);

    await controller.close();
    refreshStream.dispose();
  });

  test('notifies listeners when refresh() is called manually', () async {
    final controller = StreamController<int>();
    final refreshStream = GoRouterRefreshStream(controller.stream);
    var notifyCount = 0;
    refreshStream.addListener(() => notifyCount++);

    refreshStream.refresh();

    expect(notifyCount, 1);

    await controller.close();
    refreshStream.dispose();
  });
}
