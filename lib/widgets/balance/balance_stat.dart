import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

String _formatAmount(double amount) => '\$${amount.toStringAsFixed(2)}';

String _formatSignedAmount(double amount) {
  if (amount == 0) return _formatAmount(0);
  final sign = amount > 0 ? '+' : '-';
  return '$sign${_formatAmount(amount.abs())}';
}

class BalanceSummaryCard extends StatelessWidget {
  const BalanceSummaryCard({
    super.key,
    required this.youOwe,
    required this.youAreOwed,
  });

  final double youOwe;
  final double youAreOwed;

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
        crossAxisAlignment: CrossAxisAlignment.start,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.muted),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _formatAmount(amount),
          style: theme.textTheme.h4.copyWith(color: color),
        ),
      ],
    );
  }
}
