import 'package:flutter_test/flutter_test.dart';
import 'package:split/models/recurring_expense.dart';

Map<String, dynamic> _ruleJson() => {
  'id': 'rec_01h',
  'groupId': 'grp_01h',
  'concept': 'Rent',
  'amount': 1000.0,
  'paidBy': {'id': 'mem_01h', 'name': 'Alex Rivera', 'isGhost': false},
  'shares': [
    {
      'member': {'id': 'mem_01h', 'name': 'Alex Rivera', 'isGhost': false},
      'amount': 1000.0,
    },
  ],
  'frequency': 'monthly',
  'interval': 1,
  'anchorDate': '2026-09-01T00:00:00Z',
  'active': true,
};

void main() {
  group('RecurringExpense.fromJson', () {
    test('parses every field', () {
      final rule = RecurringExpense.fromJson(_ruleJson());

      expect(rule.id, 'rec_01h');
      expect(rule.concept, 'Rent');
      expect(rule.amount, 1000.0);
      expect(rule.paidBy.name, 'Alex Rivera');
      expect(rule.shares, hasLength(1));
      expect(rule.frequency, 'monthly');
      expect(rule.interval, 1);
      expect(rule.anchorDate, DateTime.parse('2026-09-01T00:00:00Z'));
      expect(rule.active, isTrue);
    });
  });

  group('describeRecurrence', () {
    test('monthly/1 reads "Repeats monthly"', () {
      expect(describeRecurrence('monthly', 1), 'Se repite cada mes');
    });

    test('a value the app never produces itself still degrades sensibly', () {
      expect(describeRecurrence('weekly', 2), 'Se repite cada 2 semanas');
      expect(describeRecurrence('daily', 1), 'Se repite cada 1 día');
    });
  });
}
