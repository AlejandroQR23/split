import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:split/models/label.dart';
import 'package:split/utils/formatting.dart';

Map<String, dynamic> _labelJson({Object? color, Object? icon = '🍕'}) => {
  'id': 'lbl_01h',
  'groupId': 'grp_01h',
  'name': 'Food',
  'color': color ?? '#4CB963',
  'icon': icon,
};

void main() {
  group('Label.fromJson', () {
    test('parses a well-formed label', () {
      final label = Label.fromJson(_labelJson());

      expect(label.id, 'lbl_01h');
      expect(label.groupId, 'grp_01h');
      expect(label.name, 'Food');
      expect(label.color, colorFromHex('#4CB963'));
      expect(label.icon, '🍕');
    });

    test('parses a null icon', () {
      final label = Label.fromJson(_labelJson(icon: null));

      expect(label.icon, isNull);
    });

    test('degrades a malformed color to the default rather than throwing', () {
      final label = Label.fromJson(_labelJson(color: 'not-a-color'));

      expect(label.color, defaultLabelColor);
    });
  });

  group('CreateLabelInput.toJson', () {
    test('encodes the color as a hex string and omits a null icon', () {
      final input = CreateLabelInput(name: 'Rent', color: Colors.blue);

      final json = input.toJson();

      expect(json['name'], 'Rent');
      expect(json['color'], hexFromColor(Colors.blue));
      expect(json.containsKey('icon'), isFalse);
    });

    test('includes icon when provided', () {
      final input = CreateLabelInput(
        name: 'Food',
        color: Colors.red,
        icon: '🍕',
      );

      expect(input.toJson()['icon'], '🍕');
    });
  });
}
