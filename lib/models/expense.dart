import 'package:flutter/foundation.dart';

import 'member.dart';

/// One [Member]'s owed portion of an [Expense].
@immutable
class ExpenseShare {
  const ExpenseShare({required this.member, required this.amount});

  final Member member;
  final double amount;

  factory ExpenseShare.fromJson(Map<String, dynamic> json) => ExpenseShare(
    member: Member.fromJson(json['member']),
    amount: (json['amount'] as num).toDouble(),
  );
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

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'] as String,
    groupId: json['groupId'] as String,
    concept: json['concept'] as String,
    amount: (json['amount'] as num).toDouble(),
    paidBy: Member.fromJson(json['paidBy']),
    shares: (json['shares'] as List)
        .map((share) => ExpenseShare.fromJson(share))
        .toList(),
    date: DateTime.parse(json['date'] as String),
  );
}

class CreateExpenseInput {
  const CreateExpenseInput({
    required this.concept,
    required this.amount,
    required this.paidById,
    required this.shares,
    required this.date,
  });

  final String concept;
  final double amount;
  final String paidById;
  final List<ExpenseShareInput> shares;
  final DateTime date;

  Map<String, dynamic> toJson() => {
    'concept': concept,
    'amount': amount,
    'paidById': paidById,
    'shares': shares.map((share) => share.toJson()).toList(),
    'date': date.toIso8601String(),
  };
}

class ExpenseShareInput {
  const ExpenseShareInput({required this.memberId, required this.amount});

  final String memberId;
  final double amount;

  Map<String, dynamic> toJson() => {'memberId': memberId, 'amount': amount};
}
