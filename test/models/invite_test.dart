import 'package:flutter_test/flutter_test.dart';
import 'package:split/models/invite.dart';

void main() {
  group('InvitePreview.fromJson', () {
    test('parses a valid, unclaimed invite', () {
      final preview = InvitePreview.fromJson({
        'memberName': 'Sam Lee',
        'expired': false,
        'claimed': false,
      });

      expect(preview.memberName, 'Sam Lee');
      expect(preview.expired, isFalse);
      expect(preview.claimed, isFalse);
      expect(preview.isValid, isTrue);
    });

    test('isValid is false when expired', () {
      final preview = InvitePreview.fromJson({
        'memberName': 'Sam Lee',
        'expired': true,
        'claimed': false,
      });

      expect(preview.isValid, isFalse);
    });

    test('isValid is false when claimed', () {
      final preview = InvitePreview.fromJson({
        'memberName': 'Sam Lee',
        'expired': false,
        'claimed': true,
      });

      expect(preview.isValid, isFalse);
    });
  });

  group('GeneratedInvite.fromJson', () {
    test('parses the token and expiry', () {
      final invite = GeneratedInvite.fromJson({
        'inviteToken': 'inv_abc123',
        'expiresAt': '2026-09-22T00:00:00Z',
      });

      expect(invite.inviteToken, 'inv_abc123');
      expect(invite.expiresAt, DateTime.parse('2026-09-22T00:00:00Z'));
    });
  });
}
