import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/member.dart';
import '../../theme/app_spacing.dart';
import '../../utils/invite_share.dart';
import '../shared/avatar.dart';
import '../shared/avatar_stack.dart';

/// This group's roster, collapsed by default behind a stacked-avatar
/// summary (matching the edit group screen). Tapping expands it into a
/// vertical list showing every member's name, a "Ghost" badge for anyone
/// without a linked account, and a share action to invite them.
class GroupMembersSection extends ConsumerStatefulWidget {
  const GroupMembersSection({super.key, required this.members});

  final List<Member> members;

  @override
  ConsumerState<GroupMembersSection> createState() =>
      _GroupMembersSectionState();
}

class _GroupMembersSectionState extends ConsumerState<GroupMembersSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            children: [
              Text('Members', style: theme.textTheme.h4),
              const SizedBox(width: AppSpacing.md),
              AvatarStack(members: widget.members),
              const Spacer(),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowDown01,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topLeft,
          child: !_expanded
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final member in widget.members)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.sm,
                          ),
                          child: Row(
                            children: [
                              Avatar(name: member.name, radius: 16),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  member.name,
                                  style: theme.textTheme.large,
                                ),
                              ),
                              if (member.isGhost) ...[
                                const ShadBadge.secondary(
                                  child: Text('Ghost'),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                ShadIconButton.ghost(
                                  icon: HugeIcon(
                                    icon: HugeIcons.strokeRoundedShare08,
                                    color: theme.colorScheme.mutedForeground,
                                  ),
                                  onPressed: () => generateAndShareInvite(
                                    context,
                                    ref,
                                    member,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
