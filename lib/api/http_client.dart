import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:split/repositories/auth_repository.dart';
import 'package:split/utils/network_exception.dart';

class HttpClient extends http.BaseClient {
  final http.Client _inner;
  final AuthRepository _authRepository;

  final String baseUrl = dotenv.env['API_URL']!;

  HttpClient(this._inner, this._authRepository);

  void _checkStatusCode(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    if ([400, 401, 404, 422, 500].contains(response.statusCode) &&
        response.body.isNotEmpty) {
      final errorJson = Map<String, dynamic>.from(
        jsonDecode(response.body)['error'],
      );
      final apiError = APIError.fromJson(errorJson);

      throw NetworkException(apiError, response.statusCode);
    }

    throw NetworkException(
      APIError(message: 'Unexpected error', code: 'unexpected_error'),
      response.statusCode,
    );
  }

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

  Future<http.Response> _attempt(
    String method,
    Uri url,
    Uint8List bodyBytes, {
    required bool forceRefresh,
  }) async {
    final token = await _authRepository.getIdToken(forceRefresh: forceRefresh);

    final request = http.Request(method, url)..bodyBytes = bodyBytes;
    request.headers['Content-Type'] = 'application/json';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    final streamedResponse = await _inner.send(request);
    return http.Response.fromStream(streamedResponse);
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final newUrl = Uri.parse(baseUrl).resolveUri(request.url);
    final bodyBytes = await request.finalize().toBytes();

    var response = await _attempt(
      request.method,
      newUrl,
      bodyBytes,
      forceRefresh: false,
    );

    if (response.statusCode == 401 && _errorCode(response) == 'unauthenticated') {
      try {
        response = await _attempt(
          request.method,
          newUrl,
          bodyBytes,
          forceRefresh: true,
        );
      } catch (_) {
        await _authRepository.signOut();
        throw NetworkException(
          APIError(message: 'Session expired', code: 'unauthenticated'),
          401,
        );
      }

      if (response.statusCode == 401) {
        await _authRepository.signOut();
        throw NetworkException(
          APIError(message: 'Session expired', code: 'unauthenticated'),
          401,
        );
      }
    }

    _checkStatusCode(response);

    return http.StreamedResponse(
      Stream.fromIterable([response.bodyBytes]),
      response.statusCode,
      request: request,
      headers: response.headers,
      reasonPhrase: response.reasonPhrase,
    );
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
