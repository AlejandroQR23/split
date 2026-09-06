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

/// Whether an [Expense] is a regular shared expense or a settle-up payment
/// recorded between two members.
enum ExpenseType {
  expense,
  payment;

  /// Unknown or absent values degrade to [expense] rather than throwing, so
  /// this client survives a future server-side type it doesn't know about
  /// yet.
  static ExpenseType fromJson(Object? value) =>
      value == 'payment' ? ExpenseType.payment : ExpenseType.expense;
}

/// A group expense: paid by one [Member], owed back by one or more other
/// [Member]s in arbitrary (possibly uneven) amounts.
///
/// A settle-up payment ([type] is [ExpenseType.payment]) is also represented
/// as an [Expense]: [paidBy] is who paid, and [shares] has exactly one entry
/// (who was paid back).
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
    this.type = ExpenseType.expense,
  });

  final String id;
  final String groupId;
  final String concept;
  final double amount;
  final Member paidBy;
  final List<ExpenseShare> shares;
  final DateTime date;
  final ExpenseType type;

  bool get isPayment => type == ExpenseType.payment;

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
    type: ExpenseType.fromJson(json['type']),
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

/// Request body for `POST /groups/{groupId}/payments` — records that
/// [fromMemberId] paid [toMemberId] back, reducing (or, if it overshoots,
/// reversing) the balance between them.
class CreatePaymentInput {
  const CreatePaymentInput({
    required this.fromMemberId,
    required this.toMemberId,
    required this.amount,
    required this.date,
  });

  final String fromMemberId;
  final String toMemberId;
  final double amount;
  final DateTime date;

  Map<String, dynamic> toJson() => {
    'fromMemberId': fromMemberId,
    'toMemberId': toMemberId,
    'amount': amount,
    'date': date.toIso8601String(),
  };
}
