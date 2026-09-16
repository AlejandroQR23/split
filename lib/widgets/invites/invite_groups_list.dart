import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/group.dart';
import '../../theme/app_spacing.dart';
import 'invite_group_section.dart';

class InviteGroupsList extends StatelessWidget {
  const InviteGroupsList({
    super.key,
    required this.token,
    required this.groups,
    required this.invitedMemberName,
  });

  final String token;
  final List<Group> groups;
  final String invitedMemberName;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return Center(
        child: Text(
          'Not in any groups yet.',
          style: ShadTheme.of(context).textTheme.muted,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      children: [
        for (final group in groups) ...[
          InviteGroupSection(
            token: token,
            group: group,
            invitedMemberName: invitedMemberName,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ],
    );
  }
}
