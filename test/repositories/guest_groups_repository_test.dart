// test/repositories/guest_groups_repository_test.dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:split/repositories/guest_groups_repository.dart';

void main() {
  group('fetchGroups', () {
    test('returns every group in GET /groups', () async {
      final inner = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, 'groups');
        return http.Response(
          jsonEncode({
            'groups': [
              {
                'id': 'grp_01h',
                'name': 'Cabin trip',
                'members': [
                  {'id': 'mem_01h', 'name': 'Sam Lee', 'isGhost': true},
                  {'id': 'mem_02h', 'name': 'Alex Rivera', 'isGhost': false},
                ],
              },
            ],
          }),
          200,
        );
      });
      final repository = GuestGroupsRepositoryImpl(inner);

      final groups = await repository.fetchGroups();

      expect(groups, hasLength(1));
      expect(groups.single.name, 'Cabin trip');
      expect(groups.single.members.first.isGhost, isTrue);
    });
  });
}
