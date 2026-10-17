import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Extracts the invite token from either a `splitapp://invite/{token}` deep
/// link or a `$INVITE_WEB_URL/invite/{token}` universal/app link, or null if
/// [uri] isn't one.
///
/// Custom scheme: `invite` is the URI's *host*, not a path segment — Dart's
/// [Uri] parses whatever follows `scheme://` as the authority for any
/// scheme, custom or not (there's no special-casing like there is for
/// `http`/`https`, where the "host" is a real domain and the path naturally
/// excludes it). The token is the first (and only) path segment after that.
///
/// HTTPS: `invite` is a real path segment after the configured host, since
/// the host here is an actual domain.
String? extractInviteToken(Uri uri) {
  if (uri.scheme == 'splitapp') {
    if (uri.host != 'invite') return null;
    if (uri.pathSegments.isEmpty) return null;

    return uri.pathSegments.first;
  }

  if (uri.scheme == 'https') {
    final inviteHost = Uri.tryParse(dotenv.env['INVITE_WEB_URL'] ?? '')?.host;
    if (inviteHost == null || inviteHost.isEmpty) return null;
    if (uri.host != inviteHost) return null;
    if (uri.pathSegments.length < 2 || uri.pathSegments[0] != 'invite') {
      return null;
    }

    return uri.pathSegments[1];
  }

  return null;
}

/// Listens for invite deep/universal links, both the one that launched the
/// app (if any) and any that arrive while it's running, and invokes
/// [onToken] with the extracted token.
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
