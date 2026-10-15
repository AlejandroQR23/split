import 'package:flutter_test/flutter_test.dart';
import 'package:split/models/expense.dart';

Map<String, dynamic> _expenseJson({
  Object? type,
  Object? label,
  Object? recurringExpenseId,
}) {
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
    'recurringExpenseId': recurringExpenseId,
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

  group('Expense.fromJson — recurringExpenseId', () {
    test('parses a non-null recurringExpenseId and isRecurring is true', () {
      final expense = Expense.fromJson(
        _expenseJson(recurringExpenseId: 'rec_01h'),
      );

      expect(expense.recurringExpenseId, 'rec_01h');
      expect(expense.isRecurring, isTrue);
    });

    test('null recurringExpenseId means isRecurring is false', () {
      final expense = Expense.fromJson(_expenseJson());

      expect(expense.recurringExpenseId, isNull);
      expect(expense.isRecurring, isFalse);
    });
  });

  group('CreateExpenseInput.toJson — repeatMonthly', () {
    test('includes recurrence when repeatMonthly is true', () {
      final input = CreateExpenseInput(
        concept: 'Rent',
        amount: 1000,
        paidById: 'mem_01h',
        shares: const [ExpenseShareInput(memberId: 'mem_01h', amount: 1000)],
        date: DateTime.utc(2026, 9, 1),
        repeatMonthly: true,
      );

      expect(input.toJson()['recurrence'], {
        'frequency': 'monthly',
        'interval': 1,
      });
    });

    test('omits recurrence when repeatMonthly is false (default)', () {
      final input = CreateExpenseInput(
        concept: 'Coffee',
        amount: 5,
        paidById: 'mem_01h',
        shares: const [ExpenseShareInput(memberId: 'mem_01h', amount: 5)],
        date: DateTime.utc(2026, 9, 1),
      );

      expect(input.toJson().containsKey('recurrence'), isFalse);
    });
  });
}
