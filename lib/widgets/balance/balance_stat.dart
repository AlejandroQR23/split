import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../utils/formatting.dart';

String _formatSignedAmount(double amount) {
  if (amount == 0) return formatAmount(0);
  final sign = amount > 0 ? '+' : '-';
  return '$sign${formatAmount(amount.abs())}';
}

class BalanceSummaryCard extends StatelessWidget {
  const BalanceSummaryCard({
    super.key,
    required this.youOwe,
    required this.youAreOwed,
    this.onAddExpense,
  });

  final double youOwe;
  final double youAreOwed;

  /// Shown as an "Add expense" button when provided.
  final VoidCallback? onAddExpense;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final net = youAreOwed - youOwe;
    final netColor = net > 0
        ? theme.colorScheme.primary
        : net < 0
        ? theme.colorScheme.destructive
        : theme.colorScheme.foreground;

    return ShadCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Your balance', style: theme.textTheme.muted),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _formatSignedAmount(net),
            style: AppTypography.amountDisplay.copyWith(color: netColor),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: BalanceStat(
                  label: 'You owe',
                  amount: youOwe,
                  color: theme.colorScheme.destructive,
                ),
              ),
              Expanded(
                child: BalanceStat(
                  label: "You're owed",
                  amount: youAreOwed,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          if (onAddExpense != null) ...[
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ShadButton(
                leading: const Icon(LucideIcons.plus, size: 16),
                onPressed: onAddExpense,
                child: const Text('Add expense'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class BalanceStat extends StatelessWidget {
  const BalanceStat({
    super.key,
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: theme.textTheme.muted),
        const SizedBox(height: AppSpacing.xs),
        Text(
          formatAmount(amount),
          style: theme.textTheme.h4.copyWith(color: color),
        ),
      ],
    );
  }
}
