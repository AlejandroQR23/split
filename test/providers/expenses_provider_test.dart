import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:split/models/expense.dart';
import 'package:split/models/member.dart';
import 'package:split/providers/expenses_provider.dart';
import 'package:split/repositories/expense_repository.dart';

// A real HTTP call yields to the event loop (not just the microtask queue),
// which is what gives Riverpod's `Timer(Duration.zero, ...)` autoDispose
// check a chance to actually run mid-mutation. A repository that resolves
// via microtasks only (e.g. bare `async => value`) finishes the whole
// mutation before that timer ever fires, which is why this needs a real
// delay to reproduce the bug.
Future<T> _simulateNetworkCall<T>(T value) =>
    Future.delayed(const Duration(milliseconds: 1), () => value);

class _FakeExpenseRepository implements ExpenseRepository {
  @override
  Future<List<Expense>> fetchExpenses({int? limit}) => _simulateNetworkCall([]);

  @override
  Future<List<Expense>> fetchExpensesForGroup(String groupId) =>
      _simulateNetworkCall([]);

  @override
  Future<void> addExpense(CreateExpenseInput expense, String groupId) =>
      _simulateNetworkCall(null);

  @override
  Future<void> removeExpense(String expenseId) => _simulateNetworkCall(null);

  @override
  Future<void> updateExpense(Expense updatedExpense) =>
      _simulateNetworkCall(null);
}

void main() {
  test(
    'addEvenExpense succeeds when nothing is watching the group\'s '
    'expensesProvider — e.g. adding an expense from the home screen for a '
    'group whose own details screen (the only other watcher) isn\'t open',
    () async {
      final container = ProviderContainer(
        overrides: [
          expenseRepositoryProvider.overrideWithValue(
            _FakeExpenseRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      const groupId = 'group-1';
      final member = Member(id: 'm1', name: 'Alex');

      // Mirrors AddExpenseScreen: `ref.read(...).notifier` without any
      // `ref.watch`/`container.listen` keeping the autoDispose provider
      // alive for the duration of the mutation.
      await container
          .read(expensesProvider(groupId).notifier)
          .addEvenExpense(
            concept: 'Dinner',
            amount: 20,
            paidBy: member,
            splitBetween: [member],
          );
    },
  );
}
