import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split/models/expense.dart';
import 'package:split/repositories/expense_repository.dart';

class ExpensesNotifier extends AsyncNotifier<List<Expense>> {
  ExpensesNotifier(this.groupId);

  final String groupId;

  @override
  Future<List<Expense>> build() {
    return ref.watch(expenseRepositoryProvider).fetchExpensesForGroup(groupId);
  }

  Future<void> _mutateAndRefresh(Future<void> Function() mutation) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(expenseRepositoryProvider);
      await mutation();
      return await repository.fetchExpensesForGroup(groupId);
    });
    ref.invalidate(allExpensesProvider);
  }

  Future<void> addExpense(Expense expense) async {
    await _mutateAndRefresh(
      () => ref.read(expenseRepositoryProvider).addExpense(expense),
    );
  }

  Future<void> removeExpense(String expenseId) async {
    await _mutateAndRefresh(
      () => ref.read(expenseRepositoryProvider).removeExpense(expenseId),
    );
  }

  Future<void> updateExpense(Expense updatedExpense) async {
    await _mutateAndRefresh(
      () => ref.read(expenseRepositoryProvider).updateExpense(updatedExpense),
    );
  }
}

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl();
});

final expensesProvider =
    AsyncNotifierProvider.family<ExpensesNotifier, List<Expense>, String>(
      (groupId) => ExpensesNotifier(groupId),
    );

class AllExpensesNotifier extends AsyncNotifier<List<Expense>> {
  @override
  Future<List<Expense>> build() {
    return ref.watch(expenseRepositoryProvider).fetchExpenses();
  }
}

final allExpensesProvider =
    AsyncNotifierProvider<AllExpensesNotifier, List<Expense>>(
      AllExpensesNotifier.new,
    );
