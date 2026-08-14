import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/member.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// One other member's net balance with the current user, aggregated across
/// every expense they share in a group. Positive [netAmount] means they owe
/// the current user; negative means the current user owes them.
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

String _formatAmount(double amount) => '\$${amount.toStringAsFixed(2)}';

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
              _InitialsAvatar(name: fromName),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Icon(
                  LucideIcons.arrowRight,
                  size: 16,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
              _InitialsAvatar(name: toName),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatAmount(settlement.netAmount.abs()),
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

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.primaryTint,
      child: Text(
        initial,
        style: theme.textTheme.large.copyWith(color: theme.colorScheme.primary),
      ),
    );
  }
}
