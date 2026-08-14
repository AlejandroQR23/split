import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/providers/current_user_provider.dart';
import 'package:split/providers/expenses_provider.dart';
import 'package:split/providers/groups_provider.dart';
import 'package:split/widgets/balance/balance_stat.dart';
import 'package:split/widgets/groups/recent_groups_section.dart';
import 'package:split/widgets/history/recent_activity_section.dart';
import 'package:split/widgets/navigation/screen_header.dart';
import 'package:split/widgets/settlement/settlement_card.dart';

import '../../models/expense.dart';
import '../../models/group.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

const _recentActivityLimit = 3;
const _recentGroupsLimit = 3;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsResponse = ref.watch(groupsProvider);
    final expensesResponse = ref.watch(allExpensesProvider);
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

    final groups = groupsResponse.value;
    final expenses = expensesResponse.value;
    final groupNameById = {for (final group in groups) group.id: group.name};

    final settlements = computeSettlements(expenses, currentUser);
    final youOwe = settlements
        .where((s) => s.netAmount < 0)
        .fold(0.0, (sum, s) => sum + s.netAmount.abs());
    final youAreOwed = settlements
        .where((s) => s.netAmount > 0)
        .fold(0.0, (sum, s) => sum + s.netAmount);

    final sortedExpenses = expenses.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final recentActivityItems = [
      for (final expense in sortedExpenses.take(_recentActivityLimit))
        RecentActivityItem(
          expense: expense,
          groupName: groupNameById[expense.groupId] ?? 'Unknown group',
        ),
    ];

    final lastActivityByGroupId = <String, DateTime>{};
    for (final expense in expenses) {
      final current = lastActivityByGroupId[expense.groupId];
      if (current == null || expense.date.isAfter(current)) {
        lastActivityByGroupId[expense.groupId] = expense.date;
      }
    }
    final recentGroups =
        groups
            .where((group) => lastActivityByGroupId.containsKey(group.id))
            .toList()
          ..sort(
            (a, b) => lastActivityByGroupId[b.id]!.compareTo(
              lastActivityByGroupId[a.id]!,
            ),
          );
    final recentGroupsLimited = recentGroups.take(_recentGroupsLimit).toList();

    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.background),
      child: Column(
        children: [
          ScreenHeader(title: 'Hi, ${currentUser.name}', isMainScreen: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: AppSpacing.xxxl * 2,
              ),
              children: [
                BalanceSummaryCard(
                  youOwe: youOwe,
                  youAreOwed: youAreOwed,
                  onAddExpense: () => context.push('/add-expense'),
                ),
                const SizedBox(height: AppSpacing.xl),
                RecentActivitySection(
                  items: recentActivityItems,
                  currentUser: currentUser,
                ),
                const SizedBox(height: AppSpacing.xl),
                RecentGroupsSection(groups: recentGroupsLimited),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
