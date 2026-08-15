import 'package:split/data/mock_expenses.dart';
import 'package:split/models/expense.dart';

final delayDuration = const Duration(seconds: 2);

abstract class ExpenseRepository {
  Future<List<Expense>> fetchExpenses();
  Future<List<Expense>> fetchExpensesForGroup(String groupId);
  Future<void> addExpense(Expense expense);
  Future<void> removeExpense(String expenseId);
  Future<void> updateExpense(Expense updatedExpense);
}

class ExpenseRepositoryImpl implements ExpenseRepository {
  final List<Expense> _expenses = List.of(mockExpenses);

  @override
  Future<List<Expense>> fetchExpenses() async {
    await Future.delayed(delayDuration);
    return List.of(_expenses);
  }

  @override
  Future<List<Expense>> fetchExpensesForGroup(String groupId) async {
    await Future.delayed(delayDuration);
    return _expenses.where((expense) => expense.groupId == groupId).toList();
  }

  @override
  Future<void> addExpense(Expense expense) async {
    await Future.delayed(delayDuration);
    _expenses.add(expense);
  }

  @override
  Future<void> removeExpense(String expenseId) async {
    await Future.delayed(delayDuration);
    _expenses.removeWhere((expense) => expense.id == expenseId);
  }

  @override
  Future<void> updateExpense(Expense updatedExpense) async {
    await Future.delayed(delayDuration);
    final index = _expenses.indexWhere(
      (expense) => expense.id == updatedExpense.id,
    );
    if (index != -1) {
      _expenses[index] = updatedExpense;
    }
  }
}
