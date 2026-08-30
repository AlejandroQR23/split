import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:split/utils/network_exception.dart';

class HttpClient extends http.BaseClient {
  final http.Client _inner;
  final String _userId;

  final String baseUrl = dotenv.env['API_URL']!;

  HttpClient(this._inner, this._userId);

  void _checkStatusCode(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    if ([400, 404, 422, 500].contains(response.statusCode) &&
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

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final newUrl = Uri.parse(baseUrl).resolveUri(request.url);

    request = http.Request(request.method, newUrl)
      ..bodyBytes = await request.finalize().toBytes();

    request.headers['Content-Type'] = 'application/json';
    request.headers['X-User-Id'] = _userId;

    final response = await _inner.send(request);

    // TODO: Logic for refresh token + retry request if needed, show toast on error, etc.
    final responseBody = await http.Response.fromStream(response);
    _checkStatusCode(responseBody);

    return http.StreamedResponse(
      Stream.fromIterable([responseBody.bodyBytes]),
      responseBody.statusCode,
      request: request,
      headers: responseBody.headers,
      reasonPhrase: responseBody.reasonPhrase,
    );
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
