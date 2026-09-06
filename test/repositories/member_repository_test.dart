import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:split/repositories/member_repository.dart';

void main() {
  group('fetchMe', () {
    test('returns the Member for GET /members/me', () async {
      final inner = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, 'members/me');
        return http.Response(
          jsonEncode({'id': 'mem_01h', 'name': 'Alex Rivera'}),
          200,
        );
      });
      final repository = MemberRepositoryImpl(inner);

      final member = await repository.fetchMe();

      expect(member.id, 'mem_01h');
      expect(member.name, 'Alex Rivera');
    });
  });

  group('updateName', () {
    test('PATCHes the name and returns the updated Member', () async {
      final inner = MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.path, 'members/mem_01h');
        expect(jsonDecode(request.body), {'name': 'Alex R. Rivera'});
        return http.Response(
          jsonEncode({'id': 'mem_01h', 'name': 'Alex R. Rivera'}),
          200,
        );
      });
      final repository = MemberRepositoryImpl(inner);

      final member = await repository.updateName('mem_01h', 'Alex R. Rivera');

      expect(member.name, 'Alex R. Rivera');
    });
  });
}
