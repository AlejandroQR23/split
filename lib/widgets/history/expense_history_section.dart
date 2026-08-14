import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/expense.dart';
import '../../models/member.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

const _monthAbbreviations = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _formatDate(DateTime date) =>
    '${_monthAbbreviations[date.month - 1]} ${date.day}, ${date.year}';

String _formatAmount(double amount) => '\$${amount.toStringAsFixed(2)}';

class ExpenseHistorySection extends StatelessWidget {
  const ExpenseHistorySection({
    super.key,
    required this.expenses,
    required this.currentUser,
  });

  final List<Expense> expenses;
  final Member currentUser;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final sortedExpenses = expenses.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

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
          for (final expense in sortedExpenses) ...[
            _ExpenseHistoryTile(expense: expense, currentUser: currentUser),
            const SizedBox(height: AppSpacing.md),
          ],
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
    final initial = expense.paidBy.id == currentUser.id
        ? 'Y'
        : expense.paidBy.name.isNotEmpty
        ? expense.paidBy.name[0].toUpperCase()
        : '?';

    return ShadCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.surface,
            child: Text(
              initial,
              style: theme.textTheme.large.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.concept, style: theme.textTheme.large),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Paid by $payerLabel · ${_formatDate(expense.date)}',
                  style: theme.textTheme.muted,
                ),
              ],
            ),
          ),
          Text(
            _formatAmount(expense.amount),
            style: theme.textTheme.h4.copyWith(
              color: theme.colorScheme.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
