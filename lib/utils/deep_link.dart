import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

/// Extracts the invite token from a `splitapp://invite/{token}` deep link,
/// or null if [uri] isn't one.
///
/// `invite` is the URI's *host*, not a path segment — Dart's [Uri] parses
/// whatever follows `scheme://` as the authority for any scheme, custom or
/// not (there's no special-casing like there is for `http`/`https`, where
/// the "host" is a real domain and the path naturally excludes it). The
/// token is the first (and only) path segment after that.
String? extractInviteToken(Uri uri) {
  if (uri.scheme != 'splitapp') return null;
  if (uri.host != 'invite') return null;
  if (uri.pathSegments.isEmpty) return null;

  return uri.pathSegments.first;
}

/// Listens for `splitapp://invite/{token}` deep links, both the one that
/// launched the app (if any) and any that arrive while it's running, and
/// invokes [onToken] with the extracted token.
///
/// Deep links arrive as raw platform events, independent of whatever
/// go_router already thinks the current route is — this listens directly
/// via `app_links` rather than relying on Flutter's automatic initial-route
/// parsing. That automatic parsing would treat "invite" as the URI's host
/// and drop it from the route entirely, landing on `/{token}` instead of
/// the registered `/invites/:token` route — see [extractInviteToken]'s doc
/// comment.
void listenForInviteDeepLinks(void Function(String token) onToken) {
  void handleUri(Uri uri) {
    final token = extractInviteToken(uri);
    if (token == null) return;

    onToken(token);
  }

  final appLinks = AppLinks();
  appLinks
      .getInitialLink()
      .then((uri) {
        if (uri != null) handleUri(uri);
      })
      .catchError((error) {
        debugPrint('[deep-link-debug] getInitialLink error: $error');
      });
  appLinks.uriLinkStream.listen(
    handleUri,
    onError: (error) =>
        debugPrint('[deep-link-debug] uriLinkStream error: $error'),
  );
}
