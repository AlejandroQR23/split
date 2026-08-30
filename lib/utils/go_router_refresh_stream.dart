import 'dart:async';

import 'package:flutter/foundation.dart';

/// Bridges a [Stream] to `go_router`'s `Listenable`-based `refreshListenable`
/// so a route's `redirect` re-runs whenever the stream emits — not only on
/// navigation. `go_router` has no such adapter built in.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen(
      (_) => notifyListeners(),
      onError: (_, _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
