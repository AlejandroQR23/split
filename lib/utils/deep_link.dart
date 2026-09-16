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
