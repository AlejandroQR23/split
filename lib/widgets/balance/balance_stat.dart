import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/providers/settlement_provider.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../utils/formatting.dart';

String _formatSignedAmount(double amount) {
  if (amount == 0) return formatAmount(0);
  final sign = amount > 0 ? '+' : '-';
  return '$sign${formatAmount(amount.abs())}';
}

class BalanceSummaryCard extends ConsumerWidget {
  const BalanceSummaryCard({super.key, this.onAddExpense, this.groupId});

  /// Shown as an "Add expense" button when provided.
  final VoidCallback? onAddExpense;
  final String? groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);

    final settlementsRespone = groupId != null
        ? ref.watch(groupSettlementsProvider(groupId!))
        : ref.watch(allSettlementsProvider);

    return settlementsRespone.when(
      skipError: true,
      data: (settlements) {
        final youOwe = settlements
            .where((s) => s.netAmount < 0)
            .fold<double>(0, (sum, s) => sum + s.netAmount.abs());
        final youAreOwed = settlements
            .where((s) => s.netAmount > 0)
            .fold<double>(0, (sum, s) => sum + s.netAmount);

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
      },
      error: (error, stackTrace) {
        return Center(
          child: Text(
            'Error: $error',
            style: theme.textTheme.p.copyWith(
              color: theme.colorScheme.destructive,
            ),
          ),
        );
      },
      loading: () {
        return Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        );
      },
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
