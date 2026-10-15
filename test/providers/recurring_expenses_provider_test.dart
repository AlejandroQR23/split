import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:split/models/member.dart';
import 'package:split/models/recurring_expense.dart';
import 'package:split/providers/recurring_expenses_provider.dart';
import 'package:split/repositories/recurring_expense_repository.dart';

RecurringExpense _rule({required bool active}) => RecurringExpense(
  id: 'rec_01h',
  groupId: 'grp_01h',
  concept: 'Rent',
  amount: 1000,
  paidBy: const Member(id: 'mem_01h', name: 'Alice'),
  shares: const [],
  frequency: 'monthly',
  interval: 1,
  anchorDate: DateTime.utc(2026, 9, 1),
  active: active,
);

class _FakeRecurringExpenseRepository implements RecurringExpenseRepository {
  bool active = true;

  @override
  Future<List<RecurringExpense>> fetchRecurringExpenses(String groupId) async {
    return [_rule(active: active)];
  }

  @override
  Future<void> setActive(String recurringExpenseId, bool newActive) async {
    active = newActive;
  }
}

void main() {
  test('setActive pauses the rule and refetches from the repository', () async {
    final repository = _FakeRecurringExpenseRepository();
    final container = ProviderContainer(
      overrides: [
        recurringExpenseRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    const groupId = 'grp_01h';

    final initial = await container.read(
      recurringExpensesProvider(groupId).future,
    );
    expect(initial.single.active, isTrue);

    await container
        .read(recurringExpensesProvider(groupId).notifier)
        .setActive('rec_01h', false);

    final updated = container.read(recurringExpensesProvider(groupId));
    expect(updated.value!.single.active, isFalse);
  });
}
