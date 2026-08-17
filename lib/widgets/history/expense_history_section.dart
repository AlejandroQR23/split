import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/widgets/animations/reveal_animation_state.dart';
import 'package:split/widgets/animations/staggered_reveal_items.dart';

import '../../models/expense.dart';
import '../../models/member.dart';
import '../../theme/app_spacing.dart';
import '../../utils/formatting.dart';
import '../shared/avatar.dart';

class ExpenseHistorySection extends StatefulWidget {
  const ExpenseHistorySection({
    super.key,
    required this.expenses,
    required this.currentUser,
  });

  final List<Expense> expenses;
  final Member currentUser;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Spending history', style: theme.textTheme.h4),
            ShadBadge.secondary(
              child: Text(
                sortedExpenses.isEmpty
                    ? 'No expenses'
                    : '${sortedExpenses.length} expenses',
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
                ),
            ],
          ),
      ],
    );
  }
}

class _ExpenseHistoryTile extends StatelessWidget {
  const _ExpenseHistoryTile({required this.expense, required this.currentUser});

  final Expense expense;
  final Member currentUser;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final payerLabel = expense.paidBy.id == currentUser.id
        ? 'You'
        : expense.paidBy.name;

    return ShadCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Avatar(name: payerLabel),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.concept, style: theme.textTheme.large),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Paid by $payerLabel · ${formatDate(expense.date)}',
                  style: theme.textTheme.muted,
                ),
              ],
            ),
          ),
          Text(
            formatAmount(expense.amount),
            style: theme.textTheme.h4.copyWith(
              color: theme.colorScheme.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
