import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HttpClient extends http.BaseClient {
  final http.Client _inner;
  final String _userId;

  final String baseUrl = dotenv.env['API_URL']!;

  HttpClient(this._inner, this._userId);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final newUrl = Uri.parse(baseUrl).resolveUri(request.url);

    request = http.Request(request.method, newUrl)
      ..bodyBytes = await request.finalize().toBytes();

    request.headers['Content-Type'] = 'application/json';
    request.headers['X-User-Id'] = _userId;

    final response = await _inner.send(request);

    // TODO: Logic for refresh token + retry request if needed, show toast on error, etc.

    return response;
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
