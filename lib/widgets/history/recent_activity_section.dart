import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/expense.dart';
import '../../models/member.dart';
import '../../theme/app_spacing.dart';
import '../../utils/formatting.dart';
import '../shared/avatar.dart';

/// An [Expense] paired with the name of the group it belongs to, for
/// display in a cross-group activity feed.
class RecentActivityItem {
  const RecentActivityItem({required this.expense, required this.groupName});

  final Expense expense;
  final String groupName;
}

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({
    super.key,
    required this.items,
    required this.currentUser,
  });

  final List<RecentActivityItem> items;
  final Member currentUser;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent activity', style: theme.textTheme.h4),
        const SizedBox(height: AppSpacing.lg),
        if (items.isEmpty)
          Text('No activity yet.', style: theme.textTheme.muted)
        else
          for (final item in items) ...[
            _RecentActivityTile(item: item, currentUser: currentUser),
            const SizedBox(height: AppSpacing.md),
          ],
      ],
    );
  }
}

class _RecentActivityTile extends StatelessWidget {
  const _RecentActivityTile({required this.item, required this.currentUser});

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
