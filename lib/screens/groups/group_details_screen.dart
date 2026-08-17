import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/helpers/compute_settlements.dart';
import 'package:split/providers/current_user_provider.dart';
import 'package:split/providers/expenses_provider.dart';
import 'package:split/providers/groups_provider.dart';
import 'package:split/widgets/balance/balance_stat.dart';
import 'package:split/widgets/history/expense_history_section.dart';
import 'package:split/widgets/navigation/screen_header.dart';
import 'package:split/widgets/settlement/pending_settlement.dart';

import '../../models/expense.dart';
import '../../models/group.dart';
import '../../models/member.dart';
import '../../models/transfer.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class GroupDetailsScreen extends ConsumerWidget {
  final String groupId;

  const GroupDetailsScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsResponse = ref.watch(groupsProvider);
    final expensesResponse = ref.watch(expensesProvider(groupId));
    final currentUser = ref.watch(currentUserProvider);

    final theme = ShadTheme.of(context);

    // groupsProvider/expensesProvider keep serving their last-known-good
    // list on a failed mutation instead of surfacing an error state (see
    // _mutateAndRefresh in each), so hasError here only ever means "never
    // successfully loaded" — checking hasValue first keeps that explicit
    // rather than relying on that provider-side contract silently.
    if (groupsResponse.hasError && !groupsResponse.hasValue) {
      return Center(
        child: Text(
          'Error: ${groupsResponse.error}',
          style: theme.textTheme.p.copyWith(
            color: theme.colorScheme.destructive,
          ),
        ),
      );
    }
    if (expensesResponse.hasError && !expensesResponse.hasValue) {
      return Center(
        child: Text(
          'Error: ${expensesResponse.error}',
          style: theme.textTheme.p.copyWith(
            color: theme.colorScheme.destructive,
          ),
        ),
      );
    }
    if (!groupsResponse.hasValue || !expensesResponse.hasValue) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    final group = groupsResponse.requireValue.firstWhere(
      (g) => g.id == groupId,
    );
    final expenses = expensesResponse.requireValue;
    final transfers = computeTransfers(expenses: expenses, members: group.members);

    return _GroupDetailsContent(
      group: group,
      expenses: expenses,
      transfers: transfers,
      currentUser: currentUser,
    );
  }
}

class _GroupDetailsContent extends StatelessWidget {
  const _GroupDetailsContent({
    required this.group,
    required this.expenses,
    required this.transfers,
    required this.currentUser,
  });

  final Group group;
  final List<Expense> expenses;
  final List<Transfer> transfers;
  final Member currentUser;

  @override
  Widget build(BuildContext context) {
    final youOwe = transfers
        .where((t) => t.from == currentUser.id)
        .fold(0.0, (sum, t) => sum + t.amount);
    final youAreOwed = transfers
        .where((t) => t.to == currentUser.id)
        .fold(0.0, (sum, t) => sum + t.amount);

    final body = ListView(
      padding: const EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: AppSpacing.xxxl * 2,
      ),
      children: [
        BalanceSummaryCard(
          youOwe: youOwe,
          youAreOwed: youAreOwed,
          onAddExpense: () => context.push('/add-expense?groupId=${group.id}'),
        ),
        const SizedBox(height: AppSpacing.xl),
        PendingSettlementsSection(
          transfers: transfers,
          currentUser: currentUser,
          members: group.members,
        ),
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
