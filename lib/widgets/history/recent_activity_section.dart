import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/widgets/animations/reveal_animation_state.dart';
import 'package:split/widgets/animations/staggered_reveal_items.dart';
import 'package:split/widgets/history/recent_activity_tile.dart';

import '../../models/expense.dart';
import '../../models/member.dart';
import '../../theme/app_spacing.dart';

/// An [Expense] paired with the name of the group it belongs to, for
/// display in a cross-group activity feed.
class RecentActivityItem {
  const RecentActivityItem({required this.expense, required this.groupName});

  final Expense expense;
  final String groupName;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecentActivityItem &&
        other.expense == expense &&
        other.groupName == groupName;
  }

  @override
  int get hashCode => Object.hash(expense, groupName);
}

class RecentActivitySection extends StatefulWidget {
  const RecentActivitySection({
    super.key,
    required this.items,
    required this.currentUser,
  });

  final List<RecentActivityItem> items;
  final Member currentUser;

  @override
  State<RecentActivitySection> createState() => _RecentActivitySectionState();
}

class _RecentActivitySectionState
    extends RevealAnimationState<RecentActivitySection, RecentActivityItem> {
  @override
  List<RecentActivityItem> getItems(RecentActivitySection widget) =>
      widget.items;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent activity', style: theme.textTheme.h4),
        const SizedBox(height: AppSpacing.lg),
        if (widget.items.isEmpty)
          Text('No activity yet.', style: theme.textTheme.muted)
        else
          StaggeredRevealItems(
            animation: animationController,
            spacing: AppSpacing.md,
            children: [
              for (final item in widget.items)
                RecentActivityTile(item: item, currentUser: widget.currentUser),
            ],
          ),
      ],
    );
  }
}
