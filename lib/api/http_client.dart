import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:split/api/api_http_client.dart';
import 'package:split/repositories/auth_repository.dart';
import 'package:split/utils/network_exception.dart';

class HttpClient extends ApiHttpClient {
  HttpClient(super.inner, this._authRepository);

  final AuthRepository _authRepository;

  /// The `error.code` of a JSON error body, or null if the body isn't one.
  String? _errorCode(http.Response response) {
    if (response.body.isEmpty) return null;
    try {
      final error = jsonDecode(response.body)['error'];
      return error is Map ? error['code'] as String? : null;
    } on FormatException {
      return null;
    }
  }

  @override
  Future<http.Response> attempt(
    String method,
    Uri url,
    Uint8List bodyBytes,
  ) async {
    final token = await _authRepository.getIdToken(forceRefresh: false);
    return sendRequest(method, url, bodyBytes, bearerToken: token);
  }

  @override
  Future<http.Response> handleUnauthorized(
    http.Response response,
    String method,
    Uri url,
    Uint8List bodyBytes,
  ) async {
    if (_errorCode(response) != 'unauthenticated') return response;

    http.Response retried;
    try {
      final token = await _authRepository.getIdToken(forceRefresh: true);
      retried = await sendRequest(method, url, bodyBytes, bearerToken: token);
    } catch (_) {
      await _authRepository.signOut();
      throw NetworkException(
        APIError(message: 'Session expired', code: 'unauthenticated'),
        401,
      );
    }

    if (retried.statusCode == 401) {
      await _authRepository.signOut();
      throw NetworkException(
        APIError(message: 'Session expired', code: 'unauthenticated'),
        401,
      );
    }

    return retried;
  }
}
