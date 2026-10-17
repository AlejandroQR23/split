import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:split/utils/deep_link.dart';

void main() {
  group('extractInviteToken', () {
    group('custom scheme', () {
      test('extracts the token from a valid invite link', () {
        expect(
          extractInviteToken(Uri.parse('splitapp://invite/inv_abc123')),
          'inv_abc123',
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

    group('https universal/app link', () {
      setUp(() {
        dotenv.loadFromString(
          envString: 'INVITE_WEB_URL=https://splitapp.example.com',
        );
      });

      test('extracts the token from a valid invite link', () {
        expect(
          extractInviteToken(
            Uri.parse('https://splitapp.example.com/invite/inv_abc123'),
          ),
          'inv_abc123',
        );
      });

      test('returns null for a different host', () {
        expect(
          extractInviteToken(
            Uri.parse('https://evil.example.com/invite/inv_abc123'),
          ),
          isNull,
        );
      });

      test('returns null when there is no token segment', () {
        expect(
          extractInviteToken(Uri.parse('https://splitapp.example.com/invite')),
          isNull,
        );
      });

      test('returns null when INVITE_WEB_URL is not configured', () {
        dotenv.loadFromString(envString: '', isOptional: true);
        expect(
          extractInviteToken(
            Uri.parse('https://splitapp.example.com/invite/inv_abc123'),
          ),
          isNull,
        );
      });
    });
  });
}
