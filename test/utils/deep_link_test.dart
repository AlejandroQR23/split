import 'package:flutter_test/flutter_test.dart';
import 'package:split/utils/deep_link.dart';

void main() {
  group('extractInviteToken', () {
    test('extracts the token from a valid invite link', () {
      expect(
        extractInviteToken(Uri.parse('splitapp://invite/inv_abc123')),
        'inv_abc123',
      );
    });

    test('returns null for a different scheme', () {
      expect(
        extractInviteToken(Uri.parse('https://invite/inv_abc123')),
        isNull,
      );
    });

    test('returns null for a different host', () {
      expect(
        extractInviteToken(Uri.parse('splitapp://other/inv_abc123')),
        isNull,
      );
    });

    test('returns null when there is no token segment', () {
      expect(extractInviteToken(Uri.parse('splitapp://invite')), isNull);
    });
  });
}
