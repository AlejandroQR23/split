import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/providers/groups_provider.dart';
import 'package:split/widgets/shared/avatar_stack.dart';

import '../../models/group.dart';
import '../../theme/app_spacing.dart';

const _maxAvatars = 3;

class RecentGroupsSection extends ConsumerWidget {
  const RecentGroupsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);

    final groups = ref.watch(recentGroupsProvider);

    return groups.when(
      data: (groups) {
        final List<Widget> groupRows = [];
        for (var i = 0; i < groups.length; i += 2) {
          final group1 = groups[i];
          final group2 = i + 1 < groups.length ? groups[i + 1] : null;

          groupRows.add(
            Row(
              children: [
                Expanded(child: _RecentGroupTile(group: group1)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: group2 != null
                      ? _RecentGroupTile(group: group2)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Your groups', style: theme.textTheme.h4),
                ShadButton.link(
                  onPressed: () => context.go('/groups'),
                  child: const Text('See all'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (groups.isEmpty)
              Text('No active groups yet.', style: theme.textTheme.muted)
            else
              Column(
                spacing: AppSpacing.md,
                children: groupRows
                    .animate(interval: 120.ms)
                    .fade(duration: 300.ms),
              ),
          ],
        );
      },
      error: (error, stackTrace) {
        return Center(
          child: Text(
            'Error: $error',
            style: theme.textTheme.p.copyWith(
              color: theme.colorScheme.destructive,
            ),
          ),
        );
      },
      loading: () {
        return Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        );
      },
    );
  }
}

class _RecentGroupTile extends StatelessWidget {
  const _RecentGroupTile({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final shownMembers = group.members.take(_maxAvatars).toList();
    final remaining = group.members.length - shownMembers.length;

    return GestureDetector(
      onTap: () => context.go('/groups/group/${group.id}'),
      child: ShadCard(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AvatarStack(members: shownMembers),
                if (remaining > 0) ...[
                  const SizedBox(width: AppSpacing.md),
                  ShadBadge.secondary(child: Text('$remaining+')),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(group.name, style: theme.textTheme.large),
          ],
        ),
      ),
    );
  }
}
