import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:split/models/member.dart';
import 'package:split/widgets/history/recent_activity_section.dart';

import '../../utils/formatting.dart';
import 'expense_tile_content.dart';

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

    return GestureDetector(
      onTap: () => context.go('/groups/group/${expense.groupId}'),
      child: ExpenseTileContent(
        expense: expense,
        currentUser: currentUser,
        subtitleDetail: item.groupName,
        trailing: Text(formatDate(expense.date), style: theme.textTheme.muted),
      ),
    );
  }
}
