import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/member.dart';
import '../../theme/app_spacing.dart';
import '../shared/avatar_stack.dart';

/// Form body shared by [CreateGroupScreen] and [EditGroupScreen]: a group
/// name plus a dynamic list of member names to invite. [existingMembers] are
/// shown read-only above the editable rows — this form only ever adds new
/// members, it never removes one already in the group.
class GroupForm extends StatelessWidget {
  const GroupForm({
    super.key,
    required this.formKey,
    required this.memberControllers,
    required this.onAddMemberField,
    required this.onRemoveMemberField,
    required this.membersHint,
    this.initialName,
    this.existingMembers = const [],
  });

  final GlobalKey<ShadFormState> formKey;
  final List<TextEditingController> memberControllers;
  final VoidCallback onAddMemberField;
  final ValueChanged<int> onRemoveMemberField;
  final String membersHint;
  final String? initialName;
  final List<Member> existingMembers;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    final fieldLabelStyle = theme.textTheme.muted.copyWith(
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.foreground,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      children: [
        ShadForm(
          key: formKey,
          child: ShadInputFormField(
            id: 'name',
            label: const Text('Group name'),
            placeholder: const Text('Cabin trip, roommates…'),
            initialValue: initialName,
            validator: (v) {
              if (v.trim().isEmpty) return 'Enter a group name';
              return null;
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Members', style: fieldLabelStyle),
        const SizedBox(height: AppSpacing.xs),
        Text(membersHint, style: theme.textTheme.muted),
        const SizedBox(height: AppSpacing.sm),
        if (existingMembers.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AvatarStack(members: existingMembers),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  existingMembers.map((member) => member.name).join(', '),
                  style: theme.textTheme.muted,
                ),
              ],
            ),
          ),
        for (var i = 0; i < memberControllers.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: ShadInput(
                    controller: memberControllers[i],
                    placeholder: const Text('Member name'),
                  ),
                ),
                if (memberControllers.length > 1)
                  ShadIconButton.ghost(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedCancel01,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    onPressed: () => onRemoveMemberField(i),
                  ),
              ],
            ),
          ),
        ShadButton.outline(
          onPressed: onAddMemberField,
          child: const Text('Add another member'),
        ),
      ],
    );
  }
}
