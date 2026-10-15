import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:split/models/recurring_expense.dart';

abstract class RecurringExpenseRepository {
  Future<List<RecurringExpense>> fetchRecurringExpenses(String groupId);
  Future<void> setActive(String recurringExpenseId, bool active);
}

class RecurringExpenseRepositoryImpl implements RecurringExpenseRepository {
  final http.Client _client;

  RecurringExpenseRepositoryImpl(this._client);

  @override
  Future<List<RecurringExpense>> fetchRecurringExpenses(
    String groupId,
  ) async {
    final response = await _client.get(
      Uri.parse('groups/$groupId/recurring-expenses'),
    );

    final data =
        jsonDecode(response.body)['recurringExpenses'] as List<dynamic>;

    return data.map((rule) => RecurringExpense.fromJson(rule)).toList();
  }

  @override
  Future<void> setActive(String recurringExpenseId, bool active) async {
    await _client.patch(
      Uri.parse('recurring-expenses/$recurringExpenseId'),
      body: jsonEncode({'active': active}),
    );
  }
}
