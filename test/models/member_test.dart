import 'package:flutter_test/flutter_test.dart';
import 'package:split/models/member.dart';

void main() {
  group('Member.fromJson', () {
    test('parses isGhost true', () {
      final member = Member.fromJson({
        'id': 'mem_01h',
        'name': 'Sam Lee',
        'isGhost': true,
      });

      expect(member.isGhost, isTrue);
    });

    test('parses isGhost false', () {
      final member = Member.fromJson({
        'id': 'mem_01h',
        'name': 'Alex Rivera',
        'isGhost': false,
      });

      expect(member.isGhost, isFalse);
    });
  });

  group('Member()', () {
    test('defaults isGhost to false when not specified', () {
      const member = Member(id: 'mem_01h', name: 'Alex Rivera');

      expect(member.isGhost, isFalse);
    });
  });
}
