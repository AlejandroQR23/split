import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:split/api/api_http_client.dart';

/// An `http.BaseClient` for browsing via an invite token instead of a
/// Firebase session — deliberately doesn't override [handleUnauthorized]:
/// an invite token never refreshes, so there's no force-refresh-and-retry
/// dance, and a 401 here just means "this invite is no longer valid," not
/// "sign the user out." Every request gets the same fixed bearer for the
/// client's whole lifetime.
class GuestHttpClient extends ApiHttpClient {
  GuestHttpClient(super.inner, this._inviteToken);

  final String _inviteToken;

  @override
  Future<http.Response> attempt(String method, Uri url, Uint8List bodyBytes) {
    return sendRequest(method, url, bodyBytes, bearerToken: _inviteToken);
  }
}
