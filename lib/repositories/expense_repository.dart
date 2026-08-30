import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:split/models/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> fetchExpenses({int? limit});
  Future<List<Expense>> fetchExpensesForGroup(String groupId);
  Future<void> addExpense(CreateExpenseInput expense, String groupId);
  Future<void> removeExpense(String expenseId);
  Future<void> updateExpense(Expense updatedExpense);
}

class ExpenseRepositoryImpl implements ExpenseRepository {
  final http.Client _client;
  final String _userId;

  ExpenseRepositoryImpl(this._client, this._userId);

  @override
  Future<List<Expense>> fetchExpenses({int? limit}) async {
    final response = await _client.get(
      Uri.parse('members/$_userId/expenses').replace(
        queryParameters: {if (limit != null) 'limit': limit.toString()},
      ),
    );

    final data = jsonDecode(response.body)['expenses'] as List<dynamic>;

    return data.map((expense) => Expense.fromJson(expense)).toList();
  }

  @override
  Future<List<Expense>> fetchExpensesForGroup(String groupId) async {
    final response = await _client.get(Uri.parse('groups/$groupId/expenses'));

    final data = jsonDecode(response.body)['expenses'] as List<dynamic>;

    return data.map((expense) => Expense.fromJson(expense)).toList();
  }

  @override
  Future<void> addExpense(CreateExpenseInput expense, String groupId) async {
    await _client.post(
      Uri.parse('groups/$groupId/expenses'),
      body: jsonEncode(expense.toJson()),
    );
  }

  @override
  Future<void> removeExpense(String expenseId) async {
    await _client.delete(Uri.parse('expenses/$expenseId'));
  }

  @override
  Future<void> updateExpense(Expense updatedExpense) async {
    await _client.patch(
      Uri.parse('expenses/${updatedExpense.id}'),
      body: jsonEncode({
        'concept': updatedExpense.concept,
        'amount': updatedExpense.amount,
        'paidById': updatedExpense.paidBy.id,
        'shares': updatedExpense.shares
            .map(
              (share) => {'memberId': share.member.id, 'amount': share.amount},
            )
            .toList(),
        'date': updatedExpense.date.toIso8601String(),
      }),
    );
  }
}
