import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/models/expense.dart';
import 'package:split/models/member.dart';
import 'package:split/models/recurring_expense.dart';
import 'package:split/providers/recurring_expenses_provider.dart';
import 'package:split/repositories/recurring_expense_repository.dart';
import 'package:split/widgets/history/expense_history_section.dart';

const _alice = Member(id: 'mem_01h', name: 'Alice');
const _bob = Member(id: 'mem_02h', name: 'Bob');

class _FakeRecurringExpenseRepository implements RecurringExpenseRepository {
  bool active = true;

  @override
  Future<List<RecurringExpense>> fetchRecurringExpenses(String groupId) async {
    return [
      RecurringExpense(
        id: 'rec_01h',
        groupId: groupId,
        concept: 'Rent',
        amount: 1000,
        paidBy: _alice,
        shares: const [ExpenseShare(member: _alice, amount: 1000)],
        frequency: 'monthly',
        interval: 1,
        anchorDate: DateTime.utc(2026, 9, 1),
        active: active,
      ),
    ];
  }

  @override
  Future<void> setActive(String recurringExpenseId, bool newActive) async {
    active = newActive;
  }
}

class _ThrowingRecurringExpenseRepository
    implements RecurringExpenseRepository {
  @override
  Future<List<RecurringExpense>> fetchRecurringExpenses(
    String groupId,
  ) async {
    throw Exception('network down');
  }

  @override
  Future<void> setActive(String recurringExpenseId, bool newActive) async {}
}

/// Simulates stale/desynced data: the expense carries a
/// `recurringExpenseId` that isn't in the group's current rule list (e.g.
/// the rule was deleted server-side after the expense list was fetched).
class _EmptyRecurringExpenseRepository implements RecurringExpenseRepository {
  @override
  Future<List<RecurringExpense>> fetchRecurringExpenses(
    String groupId,
  ) async {
    return const [];
  }

  @override
  Future<void> setActive(String recurringExpenseId, bool newActive) async {}
}

Widget _wrap({
  required List<Expense> expenses,
  RecurringExpenseRepository? repository,
}) {
  return ProviderScope(
    overrides: [
      if (repository != null)
        recurringExpenseRepositoryProvider.overrideWithValue(repository),
    ],
    child: ShadApp(
      home: Scaffold(
        body: ExpenseHistorySection(
          expenses: expenses,
          currentUser: _alice,
          groupId: 'grp_01h',
        ),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'tapping a non-recurring expense opens a details sheet with date, '
    'payer and shares, and never touches the recurring provider',
    (tester) async {
      final expense = Expense(
        id: 'exp_01h',
        groupId: 'grp_01h',
        concept: 'Groceries',
        amount: 2000,
        paidBy: _alice,
        shares: const [
          ExpenseShare(member: _alice, amount: 1000),
          ExpenseShare(member: _bob, amount: 1000),
        ],
        date: DateTime.utc(2026, 9, 1),
      );

      await tester.pumpWidget(_wrap(expenses: [expense]));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Groceries'));
      await tester.pumpAndSettle();

      expect(find.text('Groceries'), findsWidgets);
      expect(find.text('1 sep 2026'), findsOneWidget);
      expect(find.text('Pagaste tú'), findsOneWidget);
      expect(find.text('Dividido en partes iguales entre 2 personas'), findsOneWidget);
      expect(find.textContaining('Bob'), findsOneWidget);
      expect(find.text('Pausar'), findsNothing);
      expect(find.text('Reanudar'), findsNothing);
    },
  );

  testWidgets(
    "a recurring expense's details sheet shows the recurrence description "
    'and a Pause button that flips to Resume without closing the sheet',
    (tester) async {
      final repository = _FakeRecurringExpenseRepository();
      final expense = Expense(
        id: 'exp_01h',
        groupId: 'grp_01h',
        concept: 'Rent',
        amount: 1000,
        paidBy: _alice,
        shares: const [ExpenseShare(member: _alice, amount: 1000)],
        date: DateTime.utc(2026, 9, 1),
        recurringExpenseId: 'rec_01h',
      );

      await tester.pumpWidget(
        _wrap(expenses: [expense], repository: repository),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rent').first);
      await tester.pumpAndSettle();

      expect(find.text('Se repite cada mes'), findsOneWidget);
      expect(find.text('Pausar'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is HugeIcon && widget.icon == HugeIcons.strokeRoundedPause,
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Pausar'));
      await tester.pumpAndSettle();

      expect(repository.active, isFalse);
      expect(find.text('Reanudar'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is HugeIcon && widget.icon == HugeIcons.strokeRoundedPlay,
        ),
        findsOneWidget,
      );
      // The sheet stays open after a successful toggle, and the recurrence
      // label now flags the paused state.
      expect(find.text('Se repite cada mes (pausado)'), findsOneWidget);
      expect(find.text('Se repite cada mes'), findsNothing);
    },
  );

  testWidgets(
    'shows an inline error (not a toast) when fetching the recurring rule '
    'fails, with no Pause button',
    (tester) async {
      final expense = Expense(
        id: 'exp_01h',
        groupId: 'grp_01h',
        concept: 'Rent',
        amount: 1000,
        paidBy: _alice,
        shares: const [ExpenseShare(member: _alice, amount: 1000)],
        date: DateTime.utc(2026, 9, 1),
        recurringExpenseId: 'rec_01h',
      );

      await tester.pumpWidget(
        _wrap(
          expenses: [expense],
          repository: _ThrowingRecurringExpenseRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rent').first);
      await tester.pumpAndSettle();

      expect(find.textContaining('network down'), findsOneWidget);
      expect(find.byType(ShadToast), findsNothing);
      expect(find.text('Pausar'), findsNothing);
    },
  );

  testWidgets(
    "shows 'Could not find this recurring expense' inline when the fetched "
    "rules don't include the expense's recurringExpenseId",
    (tester) async {
      final expense = Expense(
        id: 'exp_01h',
        groupId: 'grp_01h',
        concept: 'Rent',
        amount: 1000,
        paidBy: _alice,
        shares: const [ExpenseShare(member: _alice, amount: 1000)],
        date: DateTime.utc(2026, 9, 1),
        recurringExpenseId: 'rec_01h',
      );

      await tester.pumpWidget(
        _wrap(
          expenses: [expense],
          repository: _EmptyRecurringExpenseRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rent').first);
      await tester.pumpAndSettle();

      expect(
        find.text('No se encontró este gasto recurrente.'),
        findsOneWidget,
      );
      expect(find.text('Pausar'), findsNothing);
    },
  );

  testWidgets('tapping a payment tile does not open any sheet', (
    tester,
  ) async {
    final payment = Expense(
      id: 'exp_pay',
      groupId: 'grp_01h',
      concept: 'Settle up',
      amount: 500,
      paidBy: _alice,
      shares: const [ExpenseShare(member: _bob, amount: 500)],
      date: DateTime.utc(2026, 9, 1),
      type: ExpenseType.payment,
    );

    await tester.pumpWidget(_wrap(expenses: [payment]));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tú le pagaste a Bob'));
    await tester.pumpAndSettle();

    expect(find.byType(ShadSheet), findsNothing);
  });
}
