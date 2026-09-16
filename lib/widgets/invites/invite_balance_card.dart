import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/transfer.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../utils/formatting.dart';
import '../balance/balance_stat.dart';
import '../shared/animated_amount_text.dart';

/// [BalanceSummaryCard] can't be reused here: it derives balances from
/// `groupSettlementsProvider`, which is scoped to the authenticated
/// `currentMemberProvider` and requires an authenticated http client — a
/// guest browsing via invite token has neither. This computes the same
/// owes/is-owed/net figures directly from the (already guest-fetched,
/// member-filtered) transfer list instead.
class InviteBalanceCard extends StatelessWidget {
  const InviteBalanceCard({
    super.key,
    required this.memberName,
    required this.memberId,
    required this.transfers,
  });

  final String memberName;
  final String memberId;
  final List<Transfer> transfers;

  static String _formatSignedAmount(double amount) {
    if (amount == 0) return formatAmount(0);
    final sign = amount > 0 ? '+' : '-';
    return '$sign${formatAmount(amount.abs())}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final owes = transfers
        .where((transfer) => transfer.from == memberId)
        .fold<double>(0, (sum, transfer) => sum + transfer.amount);
    final isOwed = transfers
        .where((transfer) => transfer.to == memberId)
        .fold<double>(0, (sum, transfer) => sum + transfer.amount);
    final net = isOwed - owes;
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
          Text("$memberName's balance", style: theme.textTheme.muted),
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
                  label: 'Owes',
                  amount: owes,
                  color: theme.colorScheme.destructive,
                ),
              ),
              Expanded(
                child: BalanceStat(
                  label: 'Is owed',
                  amount: isOwed,
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
