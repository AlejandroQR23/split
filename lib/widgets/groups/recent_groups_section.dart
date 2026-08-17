import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/group.dart';
import '../../models/member.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../shared/avatar.dart';

const _maxAvatars = 3;
const _avatarOuterDiameter = 32.0;
const _avatarStep = 18.0;

class RecentGroupsSection extends StatelessWidget {
  const RecentGroupsSection({super.key, required this.groups});

  final List<Group> groups;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

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
                _AvatarStack(members: shownMembers),
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

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.members});

  final List<Member> members;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox.shrink();

    final theme = ShadTheme.of(context);
    final width = _avatarOuterDiameter + _avatarStep * (members.length - 1);

    return SizedBox(
      width: width,
      height: _avatarOuterDiameter,
      child: Stack(
        children: [
          for (var i = 0; i < members.length; i++)
            Positioned(
              left: i * _avatarStep,
              child: Avatar(
                name: members[i].name,
                radius: _avatarOuterDiameter / 2 - 2,
                textStyle: theme.textTheme.small,
                ringColor: AppColors.background,
              ),
            ),
        ],
      ),
    );
  }
}
