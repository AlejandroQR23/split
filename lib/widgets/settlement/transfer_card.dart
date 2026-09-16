import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/member.dart';
import '../../models/transfer.dart';
import '../../screens/groups/settle_up_screen.dart';
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
    required this.groupId,
  });

  final Transfer transfer;
  final Member currentUser;
  final Map<String, Member> memberById;

  final String groupId;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final youOwe = transfer.from == currentUser.id;
    final youAreOwed = transfer.to == currentUser.id;
    final involvesMe = youOwe || youAreOwed;
    final amountColor = youOwe
        ? theme.colorScheme.destructive
        : youAreOwed
        ? theme.colorScheme.primary
        : theme.colorScheme.foreground;
    final fromName = youOwe ? 'You' : memberById[transfer.from]!.name;
    final toName = youAreOwed ? 'You' : memberById[transfer.to]!.name;

    final card = ShadCard(
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
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowRight01,
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
                  if (involvesMe)
                    ShadBadge(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Settle up'),
                          const SizedBox(width: AppSpacing.xs),
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowRight01,
                            size: 12,
                            color: theme.colorScheme.primaryForeground,
                          ),
                        ],
                      ),
                    )
                  else
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

    if (!involvesMe) return card;

    return GestureDetector(
      onTap: () => showShadSheet(
        context: context,
        useRootNavigator: true,
        builder: (context) => SettleUpScreen(
          groupId: groupId,
          fromMemberId: transfer.from,
          toMemberId: transfer.to,
          suggestedAmount: transfer.amount,
        ),
      ),
      child: card,
    );
  }
}
