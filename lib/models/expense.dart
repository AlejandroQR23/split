import 'package:flutter/foundation.dart';

import 'member.dart';

/// One [Member]'s owed portion of an [Expense].
@immutable
class ExpenseShare {
  const ExpenseShare({required this.member, required this.amount});

  final Member member;
  final double amount;
}

/// A group expense: paid by one [Member], owed back by one or more other
/// [Member]s in arbitrary (possibly uneven) amounts.
@immutable
class Expense {
  const Expense({
    required this.id,
    required this.groupId,
    required this.concept,
    required this.amount,
    required this.paidBy,
    required this.shares,
    required this.date,
  });

  final String id;
  final String groupId;
  final String concept;
  final double amount;
  final Member paidBy;
  final List<ExpenseShare> shares;
  final DateTime date;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense && other.id == id && other.groupId == groupId;
  }

  @override
  int get hashCode => Object.hash(id, groupId);
}
