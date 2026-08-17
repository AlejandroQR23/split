import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/member.dart';
import '../../models/transfer.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/formatting.dart';
import '../shared/avatar.dart';

class TransferCard extends StatelessWidget {
  const TransferCard({
    super.key,
    required this.transfer,
    required this.currentUser,
    required this.memberById,
  });

  final Transfer transfer;
  final Member currentUser;
  final Map<String, Member> memberById;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final youOwe = transfer.from == currentUser.id;
    final youAreOwed = transfer.to == currentUser.id;
    final amountColor = youOwe
        ? theme.colorScheme.destructive
        : youAreOwed
        ? theme.colorScheme.primary
        : theme.colorScheme.foreground;
    final fromName = youOwe ? 'You' : memberById[transfer.from]!.name;
    final toName = youAreOwed ? 'You' : memberById[transfer.to]!.name;

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
                    formatAmount(transfer.amount),
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
        ],
      ),
    );
  }
}
