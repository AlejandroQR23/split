import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/providers/current_user_provider.dart';
import 'package:split/providers/expenses_provider.dart';
import 'package:split/providers/groups_provider.dart';
import 'package:split/widgets/balance/balance_stat.dart';
import 'package:split/widgets/history/expense_history_section.dart';
import 'package:split/widgets/navigation/screen_header.dart';
import 'package:split/widgets/settlement/pending_settlement.dart';
import 'package:split/widgets/settlement/settlement_card.dart';

import '../../models/expense.dart';
import '../../models/group.dart';
import '../../models/member.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

List<Settlement> _computeSettlements(
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

class GroupDetailsScreen extends ConsumerWidget {
  final String groupId;

  const GroupDetailsScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsResponse = ref.watch(groupsProvider);
    final expensesResponse = ref.watch(expensesProvider(groupId));
    final currentUser = ref.watch(currentUserProvider);

    final theme = ShadTheme.of(context);

    if (groupsResponse is AsyncError) {
      return Center(
        child: Text(
          'Error: ${groupsResponse.error}',
          style: theme.textTheme.p.copyWith(
            color: theme.colorScheme.destructive,
          ),
        ),
      );
    }
    if (expensesResponse is AsyncError) {
      return Center(
        child: Text(
          'Error: ${expensesResponse.error}',
          style: theme.textTheme.p.copyWith(
            color: theme.colorScheme.destructive,
          ),
        ),
      );
    }
    if (groupsResponse is! AsyncData<List<Group>> ||
        expensesResponse is! AsyncData<List<Expense>>) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    final group = groupsResponse.value.firstWhere((g) => g.id == groupId);
    final expenses = expensesResponse.value;
    final settlements = _computeSettlements(expenses, currentUser);

    return _GroupDetailsContent(
      group: group,
      expenses: expenses,
      settlements: settlements,
      currentUser: currentUser,
    );
  }
}

class _GroupDetailsContent extends StatelessWidget {
  const _GroupDetailsContent({
    required this.group,
    required this.expenses,
    required this.settlements,
    required this.currentUser,
  });

  final Group group;
  final List<Expense> expenses;
  final List<Settlement> settlements;
  final Member currentUser;

  @override
  Widget build(BuildContext context) {
    final youOwe = settlements
        .where((s) => s.netAmount < 0)
        .fold(0.0, (sum, s) => sum + s.netAmount.abs());
    final youAreOwed = settlements
        .where((s) => s.netAmount > 0)
        .fold(0.0, (sum, s) => sum + s.netAmount);

    final body = ListView(
      padding: const EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: AppSpacing.xxxl * 2,
      ),
      children: [
        BalanceSummaryCard(youOwe: youOwe, youAreOwed: youAreOwed),
        const SizedBox(height: AppSpacing.xl),
        PendingSettlementsSection(settlements: settlements),
        const SizedBox(height: AppSpacing.xl),
        ExpenseHistorySection(expenses: expenses, currentUser: currentUser),
      ],
    );

    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.background),
      child: Column(
        children: [
          ScreenHeader(title: group.name),
          Expanded(child: body),
        ],
      ),
    );
  }
}
