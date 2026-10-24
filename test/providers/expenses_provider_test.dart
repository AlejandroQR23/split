import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:split/models/expense.dart';
import 'package:split/models/member.dart';
import 'package:split/providers/analytics_provider.dart';
import 'package:split/providers/expenses_provider.dart';
import 'package:split/repositories/expense_repository.dart';

import '../fakes/fake_analytics_service.dart';

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
  Future<void> addPayment(CreatePaymentInput payment, String groupId) =>
      _simulateNetworkCall(null);

  @override
  Future<void> removeExpense(String expenseId) => _simulateNetworkCall(null);

  @override
  Future<void> updateExpense(Expense updatedExpense) =>
      _simulateNetworkCall(null);
}

class _FailingAddExpenseRepository extends _FakeExpenseRepository {
  @override
  Future<void> addExpense(CreateExpenseInput expense, String groupId) =>
      Future.error(Exception('boom'));
}

/// Records `addPayment` calls and, once one has succeeded, starts returning
/// a single payment `Expense` from `fetchExpensesForGroup` — enough to
/// assert `settleUp` triggers a real refetch rather than patching state
/// locally.
class _RecordingExpenseRepository implements ExpenseRepository {
  final List<CreatePaymentInput> paymentCalls = [];
  bool failNextPayment = false;

  @override
  Future<List<Expense>> fetchExpenses({int? limit}) => _simulateNetworkCall([]);

  @override
  Future<List<Expense>> fetchExpensesForGroup(String groupId) {
    if (paymentCalls.isEmpty) return _simulateNetworkCall([]);
    return _simulateNetworkCall([
      Expense(
        id: 'exp-payment',
        groupId: groupId,
        concept: 'Settle up',
        amount: paymentCalls.last.amount,
        paidBy: Member(id: paymentCalls.last.fromMemberId, name: 'Payer'),
        shares: [
          ExpenseShare(
            member: Member(id: paymentCalls.last.toMemberId, name: 'Payee'),
            amount: paymentCalls.last.amount,
          ),
        ],
        date: paymentCalls.last.date,
        type: ExpenseType.payment,
      ),
    ]);
  }

  @override
  Future<void> addExpense(CreateExpenseInput expense, String groupId) =>
      _simulateNetworkCall(null);

  @override
  Future<void> addPayment(CreatePaymentInput payment, String groupId) async {
    if (failNextPayment) throw Exception('boom');
    paymentCalls.add(payment);
    await _simulateNetworkCall(null);
  }

  @override
  Future<void> removeExpense(String expenseId) => _simulateNetworkCall(null);

  @override
  Future<void> updateExpense(Expense updatedExpense) =>
      _simulateNetworkCall(null);
}

class _RecordingCreateExpenseRepository implements ExpenseRepository {
  CreateExpenseInput? lastCreateInput;

  @override
  Future<List<Expense>> fetchExpenses({int? limit}) => _simulateNetworkCall([]);

  @override
  Future<List<Expense>> fetchExpensesForGroup(String groupId) =>
      _simulateNetworkCall([]);

  @override
  Future<void> addExpense(CreateExpenseInput expense, String groupId) async {
    lastCreateInput = expense;
  }

  @override
  Future<void> addPayment(CreatePaymentInput payment, String groupId) =>
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
          expenseRepositoryProvider.overrideWithValue(_FakeExpenseRepository()),
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

  test('settleUp posts a payment and refreshes the group\'s expenses from the '
      'server rather than patching state locally', () async {
    final repository = _RecordingExpenseRepository();
    final container = ProviderContainer(
      overrides: [expenseRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    const groupId = 'group-1';

    await container
        .read(expensesProvider(groupId).notifier)
        .settleUp(fromMemberId: 'm2', toMemberId: 'm1', amount: 20);

    expect(repository.paymentCalls, hasLength(1));
    expect(repository.paymentCalls.single.fromMemberId, 'm2');
    expect(repository.paymentCalls.single.toMemberId, 'm1');
    expect(repository.paymentCalls.single.amount, 20);

    final state = container.read(expensesProvider(groupId));
    expect(state.value, hasLength(1));
    expect(state.value!.single.isPayment, isTrue);
  });

  test(
    'settleUp rethrows on failure and leaves the previous data in place, '
    'for a screen that is watching the provider (e.g. GroupDetailsScreen)',
    () async {
      final repository = _RecordingExpenseRepository();
      final container = ProviderContainer(
        overrides: [expenseRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      const groupId = 'group-1';

      // Keep the autoDispose provider alive across the mutation, mirroring
      // a screen watching it rather than a one-off `ref.read`.
      final sub = container.listen(expensesProvider(groupId), (_, _) {});
      addTearDown(sub.close);

      final initial = await container.read(expensesProvider(groupId).future);
      expect(initial, isEmpty);

      repository.failNextPayment = true;

      await expectLater(
        container
            .read(expensesProvider(groupId).notifier)
            .settleUp(fromMemberId: 'm2', toMemberId: 'm1', amount: 20),
        throwsA(isA<Exception>()),
      );

      expect(repository.paymentCalls, isEmpty);
      final state = container.read(expensesProvider(groupId));
      expect(state.value, isEmpty);
    },
  );

  test('addEvenExpense forwards repeatMonthly to CreateExpenseInput', () async {
    final repository = _RecordingCreateExpenseRepository();
    final container = ProviderContainer(
      overrides: [expenseRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    const groupId = 'group-1';
    final member = Member(id: 'm1', name: 'Alex');

    await container
        .read(expensesProvider(groupId).notifier)
        .addEvenExpense(
          concept: 'Rent',
          amount: 1000,
          paidBy: member,
          splitBetween: [member],
          repeatMonthly: true,
        );

    expect(repository.lastCreateInput!.repeatMonthly, isTrue);
  });

  test(
    'addEvenExpense captures expense_created with amount and split count',
    () async {
      final analytics = FakeAnalyticsService();
      final container = ProviderContainer(
        overrides: [
          expenseRepositoryProvider.overrideWithValue(_FakeExpenseRepository()),
          analyticsServiceProvider.overrideWithValue(analytics),
        ],
      );
      addTearDown(container.dispose);
      final member = Member(id: 'm1', name: 'Alex');

      await container
          .read(expensesProvider('group-1').notifier)
          .addEvenExpense(
            concept: 'Dinner',
            amount: 20,
            paidBy: member,
            splitBetween: [member],
          );

      // Compared field-by-field rather than as a whole record: Dart record
      // equality delegates to the Map field's own `==`, which is identity-based
      // (Map doesn't override it), so two structurally-equal-but-distinct map
      // literals are never `==`.
      expect(analytics.captured, hasLength(1));
      expect(analytics.captured.single.$1, 'expense_created');
      expect(analytics.captured.single.$2, {'amount': 20.0, 'splitCount': 1});
    },
  );

  test(
    'addEvenExpense does not capture an event when the mutation fails',
    () async {
      final analytics = FakeAnalyticsService();
      final container = ProviderContainer(
        overrides: [
          expenseRepositoryProvider.overrideWithValue(
            _FailingAddExpenseRepository(),
          ),
          analyticsServiceProvider.overrideWithValue(analytics),
        ],
      );
      addTearDown(container.dispose);
      final member = Member(id: 'm1', name: 'Alex');

      await expectLater(
        container
            .read(expensesProvider('group-1').notifier)
            .addEvenExpense(
              concept: 'Dinner',
              amount: 20,
              paidBy: member,
              splitBetween: [member],
            ),
        throwsA(isA<Exception>()),
      );
      expect(analytics.captured, isEmpty);
    },
  );

  test('settleUp does not capture an event when the mutation fails', () async {
    final analytics = FakeAnalyticsService();
    final repository = _RecordingExpenseRepository()..failNextPayment = true;
    final container = ProviderContainer(
      overrides: [
        expenseRepositoryProvider.overrideWithValue(repository),
        analyticsServiceProvider.overrideWithValue(analytics),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container
          .read(expensesProvider('group-1').notifier)
          .settleUp(fromMemberId: 'm2', toMemberId: 'm1', amount: 20),
      throwsA(isA<Exception>()),
    );
    expect(analytics.captured, isEmpty);
  });

  test('settleUp captures settle_up_recorded with the amount', () async {
    final analytics = FakeAnalyticsService();
    final container = ProviderContainer(
      overrides: [
        expenseRepositoryProvider.overrideWithValue(
          _RecordingExpenseRepository(),
        ),
        analyticsServiceProvider.overrideWithValue(analytics),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(expensesProvider('group-1').notifier)
        .settleUp(fromMemberId: 'm2', toMemberId: 'm1', amount: 20);

    expect(analytics.captured, hasLength(1));
    expect(analytics.captured.single.$1, 'settle_up_recorded');
    expect(analytics.captured.single.$2, {'amount': 20.0});
  });
}
