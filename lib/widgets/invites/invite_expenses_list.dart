import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/expense.dart';
import '../../theme/app_spacing.dart';
import '../../utils/formatting.dart';
import '../history/expense_tile_content.dart';
import 'guest_viewer_sentinel.dart';

class InviteExpensesList extends StatelessWidget {
  const InviteExpensesList({super.key, required this.expenses});

  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    if (expenses.isEmpty) {
      return Text('No expenses logged yet.', style: theme.textTheme.muted);
    }

    final sorted = expenses.toList()..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: [
        for (final expense in sorted) ...[
          ExpenseTileContent(
            expense: expense,
            currentUser: guestViewerSentinel,
            subtitleDetail: formatDate(expense.date),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}
