import 'package:flutter_test/flutter_test.dart';
import 'package:split/models/expense.dart';

Map<String, dynamic> _expenseJson({Object? type, Object? label}) {
  final json = {
    'id': 'exp_01h',
    'groupId': 'grp_01h',
    'concept': 'Groceries',
    'amount': 42.25,
    'paidBy': {'id': 'mem_01h', 'name': 'Alex Rivera', 'isGhost': false},
    'shares': [
      {
        'member': {'id': 'mem_01h', 'name': 'Alex Rivera', 'isGhost': false},
        'amount': 42.25,
      },
    ],
    'date': '2026-08-22T14:30:00Z',
    'label': label,
  };
  if (type != null) json['type'] = type;
  return json;
}

void main() {
  group('Expense.fromJson', () {
    test('parses type: "payment" as ExpenseType.payment', () {
      final expense = Expense.fromJson(_expenseJson(type: 'payment'));

      expect(expense.type, ExpenseType.payment);
      expect(expense.isPayment, isTrue);
    });

    test('parses type: "expense" as ExpenseType.expense', () {
      final expense = Expense.fromJson(_expenseJson(type: 'expense'));

      expect(expense.type, ExpenseType.expense);
      expect(expense.isPayment, isFalse);
    });

    test('defaults to ExpenseType.expense when type is absent', () {
      final expense = Expense.fromJson(_expenseJson());

      expect(expense.type, ExpenseType.expense);
    });

    test('defaults to ExpenseType.expense for an unrecognized type value, so '
        'an older client survives a future server-side type', () {
      final expense = Expense.fromJson(_expenseJson(type: 'refund'));

      expect(expense.type, ExpenseType.expense);
    });
  });

  group('Expense.fromJson label', () {
    test('parses an embedded label', () {
      final expense = Expense.fromJson(
        _expenseJson(
          label: {
            'id': 'lbl_01h',
            'groupId': 'grp_01h',
            'name': 'Food',
            'color': '#4CB963',
            'icon': '🍕',
          },
        ),
      );

      expect(expense.label?.id, 'lbl_01h');
      expect(expense.label?.name, 'Food');
      expect(expense.label?.icon, '🍕');
    });

    test('defaults to null when label is absent', () {
      final expense = Expense.fromJson(_expenseJson());

      expect(expense.label, isNull);
    });
  });
}
