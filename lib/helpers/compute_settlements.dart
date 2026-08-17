import 'dart:math';
import 'package:collection/collection.dart';

import 'package:split/models/expense.dart';
import 'package:split/models/member.dart';
import 'package:split/models/settlement.dart';
import 'package:split/models/transfer.dart';

// used instead of 0.0 to avoid floating-point precision issues when comparing balances
final epsilon = 0.005;

Map<Member, double> computeBalance({
  required List<Expense> expenses,
  required List<Member> members,
}) {
  final Map<Member, double> balances = {for (var m in members) m: 0.0};

  for (final expense in expenses) {
    balances[expense.paidBy] = balances[expense.paidBy]! + expense.amount;
    for (final share in expense.shares) {
      balances[share.member] = balances[share.member]! - share.amount;
    }
  }

  return balances;
}

List<Transfer> simplifyDebts(Map<Member, double> balances) {
  final workingBalances = Map<Member, double>.from(balances);

  final creditorHeap = PriorityQueue(
    (Member a, Member b) => workingBalances[b]!.compareTo(workingBalances[a]!),
  );
  final debtorHeap = PriorityQueue(
    (Member a, Member b) => workingBalances[a]!.compareTo(workingBalances[b]!),
  );

  for (final entry in workingBalances.entries) {
    if (entry.value > epsilon) {
      creditorHeap.add(entry.key);
    } else if (entry.value < -epsilon) {
      debtorHeap.add(entry.key);
    }
  }

  final transfers = <Transfer>[];

  while (creditorHeap.isNotEmpty && debtorHeap.isNotEmpty) {
    final creditor = creditorHeap.removeFirst();
    final debtor = debtorHeap.removeFirst();

    final amount = min(workingBalances[creditor]!, -workingBalances[debtor]!);
    transfers.add(Transfer(from: debtor.id, to: creditor.id, amount: amount));

    workingBalances[creditor] = workingBalances[creditor]! - amount;
    workingBalances[debtor] = workingBalances[debtor]! + amount;

    if (workingBalances[creditor]! > epsilon) {
      creditorHeap.add(creditor);
    }
    if (workingBalances[debtor]! < -epsilon) {
      debtorHeap.add(debtor);
    }
  }

  return transfers;
}

List<Transfer> computeTransfers({
  required List<Expense> expenses,
  required List<Member> members,
}) {
  final balances = computeBalance(expenses: expenses, members: members);
  return simplifyDebts(balances);
}

/// Nets [expenses] against [currentUser] into one [Settlement] per
/// counterparty, aggregating across every expense they share and dropping
/// counterparties who net to zero.
List<Settlement> computeSettlements(
  List<Expense> expenses,
  Member currentUser,
) {
  final netByMemberId = <String, double>{};
  final memberById = <String, Member>{};
  final conceptsByMemberId = <String, List<String>>{};

  void record(Member counterparty, double amount, String concept) {
    netByMemberId.update(
      counterparty.id,
      (value) => value + amount,
      ifAbsent: () => amount,
    );
    memberById[counterparty.id] = counterparty;
    (conceptsByMemberId[counterparty.id] ??= []).add(concept);
  }

  for (final expense in expenses) {
    if (expense.paidBy.id == currentUser.id) {
      for (final share in expense.shares) {
        if (share.member.id == currentUser.id) continue;
        record(share.member, share.amount, expense.concept);
      }
    } else {
      for (final share in expense.shares) {
        if (share.member.id != currentUser.id) continue;
        record(expense.paidBy, -share.amount, expense.concept);
      }
    }
  }

  final settlements = <Settlement>[
    for (final entry in netByMemberId.entries)
      if (entry.value != 0)
        Settlement(
          member: memberById[entry.key]!,
          netAmount: entry.value,
          summary: conceptsByMemberId[entry.key]!.length == 1
              ? conceptsByMemberId[entry.key]!.first
              : '${conceptsByMemberId[entry.key]!.length} expenses',
        ),
  ];
  settlements.sort((a, b) => b.netAmount.abs().compareTo(a.netAmount.abs()));
  return settlements;
}
