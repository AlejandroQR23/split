import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:split/models/member.dart';
import 'package:split/widgets/history/recent_activity_section.dart';

import '../../theme/app_spacing.dart';
import '../../utils/formatting.dart';
import '../shared/avatar.dart';

class RecentActivityTile extends StatelessWidget {
  const RecentActivityTile({
    super.key,
    required this.item,
    required this.currentUser,
  });

  final RecentActivityItem item;
  final Member currentUser;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final expense = item.expense;
    final payerLabel = expense.paidBy.id == currentUser.id
        ? 'You'
        : expense.paidBy.name;

    return GestureDetector(
      onTap: () => context.go('/groups/group/${expense.groupId}'),
      child: ShadCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Avatar(name: payerLabel),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.concept, style: theme.textTheme.large),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Paid by $payerLabel · ${item.groupName}',
                    style: theme.textTheme.muted,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatAmount(expense.amount),
                  style: theme.textTheme.h4.copyWith(
                    color: theme.colorScheme.foreground,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(formatDate(expense.date), style: theme.textTheme.muted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
