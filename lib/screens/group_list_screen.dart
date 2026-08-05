import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../data/mock_groups.dart';
import '../models/group.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Shows every group the (hypothetical) current user belongs to, each with
/// its member names visible. Backed by [mockGroups] — static, in-memory
/// data, no repository or state management yet.
class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.background),
      child: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.xl),
          itemCount: mockGroups.length + 1,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.lg),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Text('Your groups', style: AppTypography.screenTitle);
            }
            return _GroupCard(group: mockGroups[index - 1]);
          },
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final memberCount = group.members.length;
    return ShadCard(
      title: Text(group.name, style: theme.textTheme.h4),
      description: Text(
        memberCount == 1 ? '1 member' : '$memberCount members',
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final member in group.members)
              ShadBadge.secondary(child: Text(member.name)),
          ],
        ),
      ),
    );
  }
}
