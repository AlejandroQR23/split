import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split/models/expense.dart';
import 'package:split/models/member.dart';
import 'package:split/providers/current_user_provider.dart';
import 'package:split/providers/http_provider.dart';
import 'package:split/providers/settlement_provider.dart';
import 'package:split/providers/transfer_provider.dart';
import 'package:split/repositories/expense_repository.dart';

const _recentActivityLimit = 3;
const _refetchInterval = Duration(seconds: 30);

class ExpensesNotifier extends AsyncNotifier<List<Expense>> {
  ExpensesNotifier(this.groupId);

  final String groupId;

  @override
  Future<List<Expense>> build() {
    final timer = Timer.periodic(_refetchInterval, (_) {
      ref.invalidateSelf();
      _invalidateExpensesRelated();
    });

    ref.onDispose(timer.cancel);

    return ref.watch(expenseRepositoryProvider).fetchExpensesForGroup(groupId);
  }

  Future<void> _mutateAndRefresh(Future<void> Function() mutation) async {
    final previous = state;
    try {
      final repository = ref.read(expenseRepositoryProvider);
      await mutation();
      state = AsyncData(await repository.fetchExpensesForGroup(groupId));
      _invalidateExpensesRelated();
    } catch (error, stackTrace) {
      state = previous.hasValue ? previous : AsyncError(error, stackTrace);
      rethrow;
    }
  }

  void _invalidateExpensesRelated() {
    ref.invalidate(allExpensesProvider);
    ref.invalidate(allSettlementsProvider);
    ref.invalidate(groupSettlementsProvider(groupId));
    ref.invalidate(groupTransfersProvider(groupId));
  }

  /// Builds an even-split [CreateExpenseInput] from the raw selections made on the
  /// add-expense form and saves it.
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

    final expense = CreateExpenseInput(
      concept: concept,
      amount: amount,
      paidById: paidBy.id,
      shares: [
        for (var i = 0; i < splitCount; i++)
          ExpenseShareInput(
            memberId: splitBetween[i].id,
            amount:
                (baseCents + (i == remainderIndex ? remainderCents : 0)) / 100,
          ),
      ],
      date: DateTime.now(),
    );
    await _mutateAndRefresh(
      () => ref.read(expenseRepositoryProvider).addExpense(expense, groupId),
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
  final client = ref.watch(httpClientProvider);
  final user = ref.watch(currentUserProvider);

  return ExpenseRepositoryImpl(client, user.id);
});

final expensesProvider =
    AsyncNotifierProvider.autoDispose
        .family<ExpensesNotifier, List<Expense>, String>(
          (groupId) => ExpensesNotifier(groupId),
        );

class AllExpensesNotifier extends AsyncNotifier<List<Expense>> {
  @override
  Future<List<Expense>> build() {
    return ref
        .watch(expenseRepositoryProvider)
        .fetchExpenses(limit: _recentActivityLimit);
  }
}

final allExpensesProvider =
    AsyncNotifierProvider<AllExpensesNotifier, List<Expense>>(
      AllExpensesNotifier.new,
    );
