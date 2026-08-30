import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/providers/current_user_provider.dart';
import 'package:split/providers/expenses_provider.dart';
import 'package:split/providers/groups_provider.dart';
import 'package:split/providers/transfer_provider.dart';
import 'package:split/widgets/balance/balance_stat.dart';
import 'package:split/widgets/history/expense_history_section.dart';
import 'package:split/widgets/navigation/screen_header.dart';
import 'package:split/widgets/settlement/pending_settlement.dart';
import 'package:split/widgets/shared/async_error_text.dart';

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
    final transfersResponse = ref.watch(groupTransfersProvider(groupId));
    final currentUser = ref.watch(currentUserProvider);

    final theme = ShadTheme.of(context);
    final loading = Center(
      child: CircularProgressIndicator(color: theme.colorScheme.primary),
    );

    return groupsResponse.when(
      skipError: true,
      loading: () => loading,
      error: (error, stackTrace) => AsyncErrorText(error: error),
      data: (groups) => expensesResponse.when(
        skipError: true,
        loading: () => loading,
        error: (error, stackTrace) => AsyncErrorText(error: error),
        data: (expenses) => transfersResponse.when(
          skipError: true,
          loading: () => loading,
          error: (error, stackTrace) => AsyncErrorText(error: error),
          data: (transfers) => _GroupDetailsContent(
            group: groups.firstWhere((g) => g.id == groupId),
            expenses: expenses,
            transfers: transfers,
            currentUser: currentUser,
          ),
        ),
      ),
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
    final body = ListView(
      padding: const EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: AppSpacing.xxxl * 2,
      ),
      children: [
        BalanceSummaryCard(
          groupId: group.id,
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
          ScreenHeader(
            title: group.name,
            trailing: ShadIconButton.ghost(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/groups/group/${group.id}/edit'),
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
