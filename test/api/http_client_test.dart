import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:split/api/http_client.dart';
import 'package:split/repositories/auth_repository.dart';
import 'package:split/utils/network_exception.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.normalToken, this.refreshedToken, this.refreshError});

  String? normalToken;
  String? refreshedToken;
  Object? refreshError;

  int signOutCallCount = 0;
  final List<bool> getIdTokenCalls = [];

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    getIdTokenCalls.add(forceRefresh);
    if (forceRefresh && refreshError != null) throw refreshError!;
    return forceRefresh ? refreshedToken : normalToken;
  }

  @override
  Stream<User?> authStateChanges() => Stream.value(null);

  @override
  User? get currentUser => null;

  @override
  Future<void> signIn({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<void> signUp({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    signOutCallCount++;
  }

  @override
  Future<void> updateDisplayName(String name) {
    throw UnimplementedError();
  }
}

http.Response _errorResponse(String code, int statusCode) {
  return http.Response(
    jsonEncode({
      'error': {'code': code, 'message': code},
    }),
    statusCode,
  );
}

void main() {
  setUpAll(() {
    dotenv.loadFromString(envString: 'API_URL=https://api.split.example.com');
  });

  test('attaches the auth repository\'s id token as a bearer header', () async {
    final authRepository = _FakeAuthRepository(normalToken: 'token-1');
    http.Request? capturedRequest;
    final inner = MockClient((request) async {
      capturedRequest = request;
      return http.Response('{}', 200);
    });
    final client = HttpClient(inner, authRepository);

    await client.get(Uri.parse('groups'));

    expect(capturedRequest!.headers['Authorization'], 'Bearer token-1');
  });

  test(
    'retries once with a force-refreshed token after a 401, and returns that response on success',
    () async {
      final authRepository = _FakeAuthRepository(
        normalToken: 'stale-token',
        refreshedToken: 'fresh-token',
      );
      final seenTokens = <String?>[];
      final inner = MockClient((request) async {
        seenTokens.add(request.headers['Authorization']);
        if (request.headers['Authorization'] == 'Bearer stale-token') {
          return _errorResponse('unauthenticated', 401);
        }
        return http.Response(jsonEncode({'ok': true}), 200);
      });
      final client = HttpClient(inner, authRepository);

      final response = await client.get(Uri.parse('groups'));

      expect(seenTokens, ['Bearer stale-token', 'Bearer fresh-token']);
      expect(response.statusCode, 200);
      expect(authRepository.getIdTokenCalls, [false, true]);
      expect(authRepository.signOutCallCount, 0);
    },
  );

  test('signs out when the retried request also returns 401', () async {
    final authRepository = _FakeAuthRepository(
      normalToken: 'stale-token',
      refreshedToken: 'still-bad-token',
    );
    final inner = MockClient(
      (request) async => _errorResponse('unauthenticated', 401),
    );
    final client = HttpClient(inner, authRepository);

    await expectLater(client.get(Uri.parse('groups')), throwsA(anything));

    expect(authRepository.signOutCallCount, 1);
  });

  test('signs out when refreshing the token throws', () async {
    final authRepository = _FakeAuthRepository(
      normalToken: 'stale-token',
      refreshError: Exception('network down'),
    );
    final inner = MockClient(
      (request) async => _errorResponse('unauthenticated', 401),
    );
    final client = HttpClient(inner, authRepository);

    await expectLater(client.get(Uri.parse('groups')), throwsA(anything));

    expect(authRepository.signOutCallCount, 1);
  });

  test(
    'does not refresh or sign out on a member_not_linked 401 — the token is fine, there is just no Member row yet',
    () async {
      final authRepository = _FakeAuthRepository(normalToken: 'good-token');
      final inner = MockClient(
        (request) async => _errorResponse('member_not_linked', 401),
      );
      final client = HttpClient(inner, authRepository);

      await expectLater(
        client.get(Uri.parse('members/me')),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.error.code,
            'error.code',
            'member_not_linked',
          ),
        ),
      );

      expect(authRepository.getIdTokenCalls, [false]);
      expect(authRepository.signOutCallCount, 0);
    },
  );
}
