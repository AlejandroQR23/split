import 'package:flutter_test/flutter_test.dart';
import 'package:split/models/member.dart';
import 'package:split/utils/member_label.dart';

const _me = Member(id: 'mem_01h', name: 'Alex');
const _other = Member(id: 'mem_02h', name: 'Bob');

void main() {
  group('subjectLabel', () {
    test('returns "Tú" for the current user', () {
      expect(subjectLabel(_me, currentUser: _me), 'Tú');
    });

    test("returns the member's name for anyone else", () {
      expect(subjectLabel(_other, currentUser: _me), 'Bob');
    });
  });

  group('objectLabel', () {
    test('returns "ti" for the current user, not "Tú"', () {
      expect(objectLabel(_me, currentUser: _me), 'ti');
    });

    test("returns the member's name for anyone else", () {
      expect(objectLabel(_other, currentUser: _me), 'Bob');
    });
  });
}
