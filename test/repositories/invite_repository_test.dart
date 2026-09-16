import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:split/repositories/invite_repository.dart';

void main() {
  group('fetchPreview', () {
    test('returns the InvitePreview for GET /invites/{token}', () async {
      final inner = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, 'invites/inv_abc123');
        return http.Response(
          jsonEncode({
            'memberName': 'Sam Lee',
            'expired': false,
            'claimed': false,
          }),
          200,
        );
      });
      final repository = InviteRepositoryImpl(inner);

      final preview = await repository.fetchPreview('inv_abc123');

      expect(preview.memberName, 'Sam Lee');
      expect(preview.isValid, isTrue);
    });
  });

  group('claimInvite', () {
    test('POSTs to /invites/{token}/claim and returns the linked Member', () async {
      final inner = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, 'invites/inv_abc123/claim');
        return http.Response(
          jsonEncode({'id': 'mem_01h', 'name': 'Sam Lee', 'isGhost': false}),
          200,
        );
      });
      final repository = InviteRepositoryImpl(inner);

      final member = await repository.claimInvite('inv_abc123');

      expect(member.id, 'mem_01h');
      expect(member.isGhost, isFalse);
    });
  });

  group('generateInvite', () {
    test('POSTs to /members/{memberId}/invite and returns the token', () async {
      final inner = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, 'members/mem_02h/invite');
        return http.Response(
          jsonEncode({
            'inviteToken': 'inv_xyz789',
            'expiresAt': '2026-09-22T00:00:00Z',
          }),
          200,
        );
      });
      final repository = InviteRepositoryImpl(inner);

      final invite = await repository.generateInvite('mem_02h');

      expect(invite.inviteToken, 'inv_xyz789');
    });
  });
}
