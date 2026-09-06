import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/models/settlement.dart';
import 'package:split/providers/settlement_provider.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../utils/formatting.dart';
import '../shared/animated_amount_text.dart';

String _formatSignedAmount(double amount) {
  if (amount == 0) return formatAmount(0);
  final sign = amount > 0 ? '+' : '-';
  return '$sign${formatAmount(amount.abs())}';
}

double _netAmount(List<Settlement> settlements) {
  final youOwe = settlements
      .where((s) => s.netAmount < 0)
      .fold<double>(0, (sum, s) => sum + s.netAmount.abs());
  final youAreOwed = settlements
      .where((s) => s.netAmount > 0)
      .fold<double>(0, (sum, s) => sum + s.netAmount);
  return youAreOwed - youOwe;
}

class BalanceSummaryCard extends ConsumerWidget {
  const BalanceSummaryCard({super.key, this.onAddExpense, this.groupId});

  /// Shown as an "Add expense" button when provided.
  final VoidCallback? onAddExpense;
  final String? groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);

    final settlementsProvider = groupId != null
        ? groupSettlementsProvider(groupId!)
        : allSettlementsProvider;

    ref.listen(settlementsProvider, (previous, next) {
      final previousNet = previous?.value != null
          ? _netAmount(previous!.value!)
          : null;
      final nextNet = next.value != null ? _netAmount(next.value!) : null;

      if (nextNet == 0 && previousNet != null && previousNet != 0) {
        Confetti.launch(context, options: const ConfettiOptions());
      }
    });

    final settlementsRespone = ref.watch(settlementsProvider);

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
              AnimatedAmountText(
                amount: net,
                formatter: _formatSignedAmount,
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
                    leading: const HugeIcon(
                      icon: HugeIcons.strokeRoundedPlusSign,
                      size: 16,
                    ),
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
        AnimatedAmountText(
          amount: amount,
          formatter: formatAmount,
          style: theme.textTheme.h4.copyWith(color: color),
        ),
      ],
    );
  }
}
