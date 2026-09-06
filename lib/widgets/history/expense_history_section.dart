import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/widgets/animations/reveal_animation_state.dart';
import 'package:split/widgets/animations/staggered_reveal_items.dart';

import '../../models/expense.dart';
import '../../models/member.dart';
import '../../providers/expenses_provider.dart';
import '../../theme/app_spacing.dart';
import '../../utils/formatting.dart';
import '../../utils/network_exception.dart';
import 'expense_tile_content.dart';

class ExpenseHistorySection extends StatefulWidget {
  const ExpenseHistorySection({
    super.key,
    required this.expenses,
    required this.currentUser,
    required this.groupId,
  });

  final List<Expense> expenses;
  final Member currentUser;
  final String groupId;

  @override
  State<ExpenseHistorySection> createState() => _ExpenseHistorySectionState();
}

class _ExpenseHistorySectionState
    extends RevealAnimationState<ExpenseHistorySection, Expense> {
  List<Expense> _getSortedExpenses(ExpenseHistorySection widget) {
    final sortedExpenses = widget.expenses.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return sortedExpenses;
  }

  @override
  List<Expense> getItems(ExpenseHistorySection widget) =>
      _getSortedExpenses(widget);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final sortedExpenses = _getSortedExpenses(widget);
    final expenseCount = sortedExpenses.where((e) => !e.isPayment).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Spending history', style: theme.textTheme.h4),
            ShadBadge.secondary(
              child: Text(
                expenseCount == 0 ? 'No expenses' : '$expenseCount expenses',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (sortedExpenses.isEmpty)
          Text(
            'No expenses logged in this group yet.',
            style: theme.textTheme.muted,
          )
        else
          StaggeredRevealItems(
            animation: animationController,
            spacing: AppSpacing.md,
            children: [
              for (final expense in sortedExpenses)
                _ExpenseHistoryTile(
                  expense: expense,
                  currentUser: widget.currentUser,
                  groupId: widget.groupId,
                ),
            ],
          ),
      ],
    );
  }
}

class _ExpenseHistoryTile extends ConsumerWidget {
  const _ExpenseHistoryTile({
    required this.expense,
    required this.currentUser,
    required this.groupId,
  });

  final Expense expense;
  final Member currentUser;
  final String groupId;

  Future<bool> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showShadSheet<bool>(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        return ShadSheet(
          useSafeArea: false,
          padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset),
          title: const Text('Undo this payment?'),
          description: const Text(
            "This removes the payment and the balance it settled comes back.",
          ),
          actions: [
            ShadButton.outline(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ShadButton.destructive(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Undo'),
            ),
          ],
          child: const SizedBox(height: AppSpacing.sm),
        );
      },
    );
    if (confirmed != true) return false;
    if (!context.mounted) return false;

    try {
      await ref
          .read(expensesProvider(groupId).notifier)
          .removeExpense(expense.id);
    } catch (error) {
      if (!context.mounted) return false;
      final errorMessage = error is NetworkException
          ? error.error.message
          : error.toString();
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('Could not undo payment'),
          description: Text(errorMessage),
        ),
      );
      return false;
    }
    if (!context.mounted) return true;
    ShadToaster.of(
      context,
    ).show(const ShadToast(title: Text('Payment undone')));
    return true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ExpenseTileContent(
      expense: expense,
      currentUser: currentUser,
      subtitleDetail: formatDate(expense.date),
    );

    if (!expense.isPayment) return content;

    final theme = ShadTheme.of(context);

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.destructive,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedDelete02,
              color: theme.colorScheme.destructiveForeground,
            ),
          ),
        ),
        Dismissible(
          key: ValueKey(expense.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => _confirmAndDelete(context, ref),
          child: content,
        ),
      ],
    );
  }
}
