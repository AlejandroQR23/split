import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/expense.dart';
import '../../models/member.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/formatting.dart';
import '../shared/avatar.dart';

/// One other member's net balance with the current user, aggregated across
/// every expense they share. Positive [netAmount] means they owe the
/// current user; negative means the current user owes them.
class Settlement {
  const Settlement({
    required this.member,
    required this.netAmount,
    required this.summary,
  });

  final Member member;
  final double netAmount;
  final String summary;
}

/// Nets [expenses] against [currentUser] into one [Settlement] per
/// counterparty, aggregating across every expense they share and dropping
/// counterparties who net to zero.
List<Settlement> computeSettlements(
  List<Expense> expenses,
  Member currentUser,
) {
  final netByMemberId = <String, double>{};
  final memberById = <String, Member>{};
  final conceptsByMemberId = <String, List<String>>{};

  void record(Member counterparty, double amount, String concept) {
    netByMemberId.update(
      counterparty.id,
      (value) => value + amount,
      ifAbsent: () => amount,
    );
    memberById[counterparty.id] = counterparty;
    (conceptsByMemberId[counterparty.id] ??= []).add(concept);
  }

  for (final expense in expenses) {
    if (expense.paidBy.id == currentUser.id) {
      for (final share in expense.shares) {
        if (share.member.id == currentUser.id) continue;
        record(share.member, share.amount, expense.concept);
      }
    } else {
      for (final share in expense.shares) {
        if (share.member.id != currentUser.id) continue;
        record(expense.paidBy, -share.amount, expense.concept);
      }
    }
  }

  final settlements = <Settlement>[
    for (final entry in netByMemberId.entries)
      if (entry.value != 0)
        Settlement(
          member: memberById[entry.key]!,
          netAmount: entry.value,
          summary: conceptsByMemberId[entry.key]!.length == 1
              ? conceptsByMemberId[entry.key]!.first
              : '${conceptsByMemberId[entry.key]!.length} expenses',
        ),
  ];
  settlements.sort((a, b) => b.netAmount.abs().compareTo(a.netAmount.abs()));
  return settlements;
}

class SettlementCard extends StatelessWidget {
  const SettlementCard({super.key, required this.settlement});

  final Settlement settlement;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final youOwe = settlement.netAmount < 0;
    final amountColor = youOwe
        ? theme.colorScheme.destructive
        : theme.colorScheme.primary;
    final fromName = youOwe ? 'You' : settlement.member.name;
    final toName = youOwe ? settlement.member.name : 'You';

    return ShadCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(
                name: fromName,
                backgroundColor: AppColors.primaryTint,
                foregroundColor: theme.colorScheme.primary,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Icon(
                  LucideIcons.arrowRight,
                  size: 16,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
              Avatar(
                name: toName,
                backgroundColor: AppColors.primaryTint,
                foregroundColor: theme.colorScheme.primary,
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatAmount(settlement.netAmount.abs()),
                    style: theme.textTheme.h4.copyWith(color: amountColor),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const ShadBadge.secondary(child: Text('Pending')),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('$fromName to $toName', style: theme.textTheme.large),
          const SizedBox(height: AppSpacing.xs),
          Text(settlement.summary, style: theme.textTheme.muted),
        ],
      ),
    );
  }
}
