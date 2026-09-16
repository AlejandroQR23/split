import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:split/api/guest_http_client.dart';
import 'package:split/utils/network_exception.dart';

void main() {
  setUpAll(() {
    dotenv.loadFromString(envString: 'API_URL=https://api.split.example.com');
  });

  test('attaches the invite token as a fixed bearer header', () async {
    http.Request? capturedRequest;
    final inner = MockClient((request) async {
      capturedRequest = request;
      return http.Response('{}', 200);
    });
    final client = GuestHttpClient(inner, 'inv_abc123');

    await client.get(Uri.parse('groups'));

    expect(capturedRequest!.headers['Authorization'], 'Bearer inv_abc123');
  });

  test('resolves relative URLs against API_URL', () async {
    http.Request? capturedRequest;
    final inner = MockClient((request) async {
      capturedRequest = request;
      return http.Response('{}', 200);
    });
    final client = GuestHttpClient(inner, 'inv_abc123');

    await client.get(Uri.parse('groups'));

    expect(
      capturedRequest!.url.toString(),
      'https://api.split.example.com/groups',
    );
  });

  test('throws NetworkException on a 401 without retrying', () async {
    var callCount = 0;
    final inner = MockClient((request) async {
      callCount++;
      return http.Response(
        jsonEncode({
          'error': {'code': 'unauthenticated', 'message': 'Invite expired'},
        }),
        401,
      );
    });
    final client = GuestHttpClient(inner, 'inv_abc123');

    await expectLater(
      client.get(Uri.parse('groups')),
      throwsA(
        isA<NetworkException>().having(
          (e) => e.error.code,
          'error.code',
          'unauthenticated',
        ),
      ),
    );
    expect(callCount, 1);
  });

  test('returns the response body unchanged on success', () async {
    final inner = MockClient(
      (request) async => http.Response(jsonEncode({'groups': []}), 200),
    );
    final client = GuestHttpClient(inner, 'inv_abc123');

    final response = await client.get(Uri.parse('groups'));

    expect(jsonDecode(response.body), {'groups': []});
  });
}
