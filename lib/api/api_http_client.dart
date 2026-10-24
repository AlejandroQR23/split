import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:split/services/error_reporting_service.dart';
import 'package:split/utils/network_exception.dart';

/// Shared request/response plumbing for the app's `http.BaseClient`s —
/// resolving relative URLs against `API_URL`, building the outgoing
/// request (body bytes, `Content-Type`), and translating error responses
/// into [NetworkException]. Subclasses only decide how a request gets
/// authenticated: [attempt] attaches whatever bearer token this client
/// uses, and [handleUnauthorized] decides what a 401 means for it (retry
/// with a fresh token and sign out on failure, or just let it stand).
abstract class ApiHttpClient extends http.BaseClient {
  ApiHttpClient(this._inner, {ErrorReportingService? errorReporting})
    : _errorReporting = errorReporting ?? SentryErrorReportingService();

  final http.Client _inner;
  final ErrorReportingService _errorReporting;

  final String baseUrl = dotenv.env['API_URL']!;

  /// Performs one attempt for [method]/[url]/[bodyBytes], attaching
  /// whatever authorization this client uses.
  Future<http.Response> attempt(String method, Uri url, Uint8List bodyBytes);

  /// Called when [attempt]'s response is a 401. Returns the response to use
  /// in its place — the default lets the 401 stand.
  Future<http.Response> handleUnauthorized(
    http.Response response,
    String method,
    Uri url,
    Uint8List bodyBytes,
  ) async => response;

  /// Sends [method] to [url] with [bodyBytes], attaching [bearerToken] as
  /// `Authorization: Bearer ...` when non-null.
  Future<http.Response> sendRequest(
    String method,
    Uri url,
    Uint8List bodyBytes, {
    String? bearerToken,
  }) async {
    final request = http.Request(method, url)..bodyBytes = bodyBytes;

    if (bodyBytes.isNotEmpty) {
      request.headers['Content-Type'] = 'application/json';
    }
    if (bearerToken != null) {
      request.headers['Authorization'] = 'Bearer $bearerToken';
    }

    final streamedResponse = await _inner.send(request);
    return http.Response.fromStream(streamedResponse);
  }

  void _checkStatusCode(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    if ([400, 401, 404, 422, 500].contains(response.statusCode) &&
        response.body.isNotEmpty) {
      try {
        final errorJson = Map<String, dynamic>.from(
          jsonDecode(response.body)['error'],
        );
        final exception = NetworkException(
          APIError.fromJson(errorJson),
          response.statusCode,
        );
        if (response.statusCode >= 500) {
          _errorReporting.captureException(exception, StackTrace.current);
        }
        throw exception;
      } on NetworkException {
        rethrow;
      } catch (_) {
        // Body wasn't the documented {"error": {...}} envelope (e.g. an
        // HTML gateway page) — fall through to the unmapped-response
        // reporting path.
      }
    }

    final exception = NetworkException(
      APIError(
        message: 'Ocurrió un error inesperado',
        code: 'unexpected_error',
      ),
      response.statusCode,
    );
    _errorReporting.captureException(exception, StackTrace.current);
    throw exception;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final newUrl = Uri.parse(baseUrl).resolveUri(request.url);
    final bodyBytes = await request.finalize().toBytes();

    var response = await attempt(request.method, newUrl, bodyBytes);

    if (response.statusCode == 401) {
      response = await handleUnauthorized(
        response,
        request.method,
        newUrl,
        bodyBytes,
      );
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
