import 'package:flutter_test/flutter_test.dart';
import 'package:split/models/expense.dart';

Map<String, dynamic> _expenseJson({Object? type}) {
  final json = {
    'id': 'exp_01h',
    'groupId': 'grp_01h',
    'concept': 'Groceries',
    'amount': 42.25,
    'paidBy': {'id': 'mem_01h', 'name': 'Alex Rivera'},
    'shares': [
      {
        'member': {'id': 'mem_01h', 'name': 'Alex Rivera'},
        'amount': 42.25,
      },
    ],
    'date': '2026-08-22T14:30:00Z',
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
}
