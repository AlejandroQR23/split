import 'package:flutter_test/flutter_test.dart';
import 'package:split/helpers/compute_settlements.dart';
import 'package:split/models/expense.dart';
import 'package:split/models/member.dart';
import 'package:split/models/transfer.dart';

Map<Member, double> _applyTransfers({
  required Map<Member, double> balances,
  required List<Transfer> transfers,
}) {
  final result = Map<Member, double>.from(balances);
  final membersIdMap = {for (var m in balances.keys) m.id: m};

  for (final transfer in transfers) {
    final fromMember = membersIdMap[transfer.from]!;
    final toMember = membersIdMap[transfer.to]!;

    result[fromMember] = result[fromMember]! + transfer.amount;
    result[toMember] = result[toMember]! - transfer.amount;
  }
  return result;
}

void _expectDebtsSettled({
  required Map<Member, double> balances,
  required List<Transfer> transfers,
}) {
  final newBalances = _applyTransfers(balances: balances, transfers: transfers);

  // After applying the transfers, all balances should be approximately 0
  for (final balance in newBalances.values) {
    expect(balance, closeTo(0.0, epsilon));
  }

  // No degenerate transfers (i.e., no transfer with amount <= epsilon)
  for (final transfer in transfers) {
    expect(transfer.amount, greaterThan(epsilon));
  }

  // Sum of all transfers should equal the sum of all positive balances
  final totalPositiveBalance = balances.values
      .where((balance) => balance > 0)
      .fold(0.0, (sum, balance) => sum + balance);
  final totalTransferAmount = transfers.fold(
    0.0,
    (sum, transfer) => sum + transfer.amount,
  );
  expect(totalTransferAmount, closeTo(totalPositiveBalance, epsilon));
}

void main() {
  final members = [
    Member(id: '1', name: 'Alice'),
    Member(id: '2', name: 'Bob'),
    Member(id: '3', name: 'Charlie'),
  ];
  group('Compute Balances', () {
    test('balance = 0 for every member when there is no expenses', () {
      final expenses = <Expense>[];

      final balances = computeBalance(expenses: expenses, members: members);

      // every member is present
      expect(balances.length, members.length);
      // every member has a balance of 0
      for (final balance in balances.values) {
        expect(balance, 0.0);
      }
    });

    test('balance = 0 for a member who never participates in any transfer', () {
      final expenses = [
        Expense(
          id: '1',
          groupId: 'group1',
          concept: 'Dinner',
          amount: 60.0,
          paidBy: members[0],
          shares: [
            ExpenseShare(member: members[0], amount: 20.0),
            ExpenseShare(member: members[1], amount: 40.0),
          ],
          date: DateTime.now(),
        ),
      ];

      final balances = computeBalance(expenses: expenses, members: members);

      // Charlie never participates in any transfer, so his balance should be 0
      expect(balances[members[2]], 0.0);
      // Alice paid 60 and owes 20, so her balance should be 40
      expect(balances[members[0]], 40.0);
      // Bob owes 40, so his balance should be -40
      expect(balances[members[1]], -40.0);
    });
  });

  group('Simplify Debts', () {
    test('return empty list when there are no debts', () {
      final balances = {members[0]: 0.0, members[1]: 0.0, members[2]: 0.0};

      final transfers = simplifyDebts(balances);

      expect(transfers, isEmpty);
    });

    test(
      'return a single transfer when there is only one debtor and one creditor',
      () {
        final balances = {members[0]: 50.0, members[1]: -50.0, members[2]: 0.0};

        final transfers = simplifyDebts(balances);

        // The transfer should be from Bob (the debtor) to Alice (the creditor)
        expect(transfers.length, 1);
        expect(transfers[0].from, members[1].id);
        expect(transfers[0].to, members[0].id);
        expect(transfers[0].amount, 50.0);
      },
    );

    test('return the right transfers for multiple debtors and creditors', () {
      final balances = {
        members[0]: 70.0,
        members[1]: 30.0,
        members[2]: -60.0,
        Member(id: '4', name: 'David'): -40.0,
      };

      final transfers = simplifyDebts(balances);

      expect(
        transfers.length,
        lessThanOrEqualTo(balances.length - 1),
      ); // At most n-1 transfers

      _expectDebtsSettled(balances: balances, transfers: transfers);
    });

    test('return the right transfer amount for uneven cent-splits', () {
      final balances = {
        members[0]: 100.0,
        members[1]: -33.34,
        members[2]: -33.33,
        Member(id: '4', name: 'David'): -33.33,
      };

      final transfers = simplifyDebts(balances);

      _expectDebtsSettled(balances: balances, transfers: transfers);
    });
  });

  group('Compute Transfers', () {
    test('should compute transfers correctly', () {
      final expenses = [
        Expense(
          id: '1',
          groupId: 'group1',
          concept: 'Dinner',
          amount: 90.0,
          paidBy: members[0], // Alice
          shares: [
            ExpenseShare(member: members[0], amount: 30.0), // Alice
            ExpenseShare(member: members[1], amount: 30.0), // Bob
            ExpenseShare(member: members[2], amount: 30.0), // Charlie
          ],
          date: DateTime.now(),
        ),
        Expense(
          id: '2',
          groupId: 'group1',
          concept: 'Lunch',
          amount: 30.0,
          paidBy: members[1], // Bob
          shares: [
            ExpenseShare(member: members[1], amount: 15.0), // Bob
            ExpenseShare(member: members[2], amount: 15.0), // Charlie
          ],
          date: DateTime.now(),
        ),
      ];

      final balances = computeBalance(expenses: expenses, members: members);
      final transfers = computeTransfers(expenses: expenses, members: members);

      _expectDebtsSettled(balances: balances, transfers: transfers);
    });
  });
}
