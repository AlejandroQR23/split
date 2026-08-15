import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split/models/expense.dart';
import 'package:split/models/member.dart';
import 'package:split/repositories/expense_repository.dart';

class ExpensesNotifier extends AsyncNotifier<List<Expense>> {
  ExpensesNotifier(this.groupId);

  final String groupId;

  @override
  Future<List<Expense>> build() {
    return ref.watch(expenseRepositoryProvider).fetchExpensesForGroup(groupId);
  }

  Future<void> _mutateAndRefresh(Future<void> Function() mutation) async {
    final previous = state;
    try {
      final repository = ref.read(expenseRepositoryProvider);
      await mutation();
      state = AsyncData(await repository.fetchExpensesForGroup(groupId));
      ref.invalidate(allExpensesProvider);
    } catch (error, stackTrace) {
      state = previous.hasValue ? previous : AsyncError(error, stackTrace);
      rethrow;
    }
  }

  /// Builds an even-split [Expense] from the raw selections made on the
  /// add-expense form and saves it — the screen hands over what the user
  /// picked, not a constructed [Expense].
  ///
  /// Splits in whole cents so shares always sum to exactly [amount] (a
  /// naive `amount / count` division leaves floating-point drift, e.g.
  /// $10 / 3 doesn't divide evenly). Any leftover cent(s) go to [paidBy]
  /// if they're one of the [splitBetween] members, otherwise to the first
  /// one.
  Future<void> addEvenExpense({
    required String concept,
    required double amount,
    required Member paidBy,
    required List<Member> splitBetween,
  }) async {
    final amountCents = (amount * 100).round();
    final splitCount = splitBetween.length;
    final baseCents = amountCents ~/ splitCount;
    final remainderCents = amountCents % splitCount;
    final payerIndex = splitBetween.indexWhere((m) => m.id == paidBy.id);
    final remainderIndex = payerIndex != -1 ? payerIndex : 0;

    final expense = Expense(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      groupId: groupId,
      concept: concept,
      amount: amount,
      paidBy: paidBy,
      shares: [
        for (var i = 0; i < splitCount; i++)
          ExpenseShare(
            member: splitBetween[i],
            amount:
                (baseCents + (i == remainderIndex ? remainderCents : 0)) / 100,
          ),
      ],
      date: DateTime.now(),
    );
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
