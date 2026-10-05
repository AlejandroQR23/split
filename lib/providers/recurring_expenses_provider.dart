import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split/models/recurring_expense.dart';
import 'package:split/providers/http_provider.dart';
import 'package:split/repositories/recurring_expense_repository.dart';

class RecurringExpensesNotifier extends AsyncNotifier<List<RecurringExpense>> {
  RecurringExpensesNotifier(this.groupId);

  final String groupId;

  @override
  Future<List<RecurringExpense>> build() {
    final repository = ref.watch(recurringExpenseRepositoryProvider);
    return repository.fetchRecurringExpenses(groupId);
  }

  Future<void> setActive(String recurringExpenseId, bool active) async {
    final previous = state;
    final keepAlive = ref.keepAlive();
    try {
      final repository = ref.read(recurringExpenseRepositoryProvider);
      await repository.setActive(recurringExpenseId, active);
      state = AsyncData(await repository.fetchRecurringExpenses(groupId));
    } catch (error, stackTrace) {
      state = previous.hasValue ? previous : AsyncError(error, stackTrace);
      rethrow;
    } finally {
      keepAlive.close();
    }
  }
}

final recurringExpenseRepositoryProvider =
    Provider.autoDispose<RecurringExpenseRepository>((ref) {
      final client = ref.watch(httpClientProvider);
      return RecurringExpenseRepositoryImpl(client);
    });

final recurringExpensesProvider = AsyncNotifierProvider.autoDispose
    .family<RecurringExpensesNotifier, List<RecurringExpense>, String>(
      (groupId) => RecurringExpensesNotifier(groupId),

      retry: (retryCount, error) => null,
    );
