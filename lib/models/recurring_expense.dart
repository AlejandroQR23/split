import 'package:flutter/foundation.dart';

import 'expense.dart';
import 'member.dart';

/// A recurring rule an [Expense] was generated from, or that will generate
/// future ones.
@immutable
class RecurringExpense {
  const RecurringExpense({
    required this.id,
    required this.groupId,
    required this.concept,
    required this.amount,
    required this.paidBy,
    required this.shares,
    required this.frequency,
    required this.interval,
    required this.anchorDate,
    required this.active,
  });

  final String id;
  final String groupId;
  final String concept;
  final double amount;
  final Member paidBy;
  final List<ExpenseShare> shares;
  final String frequency;
  final int interval;
  final DateTime anchorDate;
  final bool active;

  factory RecurringExpense.fromJson(Map<String, dynamic> json) =>
      RecurringExpense(
        id: json['id'] as String,
        groupId: json['groupId'] as String,
        concept: json['concept'] as String,
        amount: (json['amount'] as num).toDouble(),
        paidBy: Member.fromJson(json['paidBy']),
        shares: (json['shares'] as List)
            .map((share) => ExpenseShare.fromJson(share))
            .toList(),
        frequency: json['frequency'] as String,
        interval: json['interval'] as int,
        anchorDate: DateTime.parse(json['anchorDate'] as String),
        active: json['active'] as bool,
      );
}

String describeRecurrence(String frequency, int interval) {
  if (frequency == 'monthly' && interval == 1) return 'Repeats monthly';

  final unit = switch (frequency) {
    'daily' => 'day',
    'weekly' => 'week',
    'monthly' => 'month',
    'yearly' => 'year',
    _ => frequency,
  };
  final pluralUnit = interval == 1 ? unit : '${unit}s';
  return 'Repeats every $interval $pluralUnit';
}
