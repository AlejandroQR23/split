import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/providers/expenses_provider.dart';
import 'package:split/providers/groups_provider.dart';
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
  const RecentActivitySection({super.key, required this.currentUser});

  final Member currentUser;

  @override
  State<RecentActivitySection> createState() => _RecentActivitySectionState();
}

class _RecentActivitySectionState
    extends RevealAnimationState<RecentActivitySection, RecentActivityItem> {
  @override
  List<RecentActivityItem> getItems(RecentActivitySection widget) => [];

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Consumer(
      builder: (context, ref, _) {
        final expensesResponse = ref.watch(allExpensesProvider);

        final groupsResponse = ref.watch(groupsProvider);
        final Map<String, String> groups = groupsResponse.when(
          data: (data) => {for (var group in data) group.id: group.name},
          error: (error, stackTrace) => {},
          loading: () => {},
        );

        return expensesResponse.when(
          data: (expenses) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recent activity', style: theme.textTheme.h4),
                const SizedBox(height: AppSpacing.lg),
                if (expenses.isEmpty)
                  Text('No activity yet.', style: theme.textTheme.muted)
                else
                  StaggeredRevealItems(
                    animation: animationController,
                    spacing: AppSpacing.md,
                    children: [
                      for (final expense in expenses)
                        RecentActivityTile(
                          item: RecentActivityItem(
                            expense: expense,
                            groupName:
                                groups[expense.groupId] ?? 'Unknown group',
                          ),
                          currentUser: widget.currentUser,
                        ),
                    ],
                  ),
              ],
            );
          },
          loading: () {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          },
          error: (error, stackTrace) {
            return Center(
              child: Text(
                'Error loading expenses',
                style: theme.textTheme.muted,
              ),
            );
          },
        );
      },
    );
  }
}
