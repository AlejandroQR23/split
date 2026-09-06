import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/group.dart';
import '../../providers/groups_provider.dart';
import '../../providers/member_provider.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/groups/group_form.dart';
import 'group_form_screen.dart';

/// Form for creating a new group: a name plus any number of member names to
/// invite. Each name is created as a new [Member] via the member repository
/// before the group itself is submitted with the resulting member ids.
///
/// [isFirstGroup] renders this as the post-onboarding "create your first
/// group" nudge (see `SetNameScreen`) rather than the usual in-app "New
/// group" flow: there's nothing to pop back to, so success and "Skip for
/// now" both navigate home instead.
class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key, this.isFirstGroup = false});

  final bool isFirstGroup;

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends GroupFormScreenState<CreateGroupScreen> {
  @override
  void initState() {
    super.initState();
    memberControllers.add(TextEditingController());
  }

  @override
  String get errorToastTitle => 'Could not create group';

  @override
  Future<void> onSubmit(String name, List<String> newMemberNames) async {
    final memberRepository = ref.read(memberRepositoryProvider);
    final memberIds = [
      for (final memberName in newMemberNames)
        (await memberRepository.addMember(memberName)).id,
    ];

    await ref
        .read(groupsProvider.notifier)
        .addGroup(CreateGroupInput(name: name, memberIds: memberIds));

    if (!mounted) return;
    if (widget.isFirstGroup) {
      context.go('/');
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = GroupForm(
      formKey: formKey,
      memberControllers: memberControllers,
      isSubmitting: isSubmitting,
      onAddMemberField: addMemberField,
      onRemoveMemberField: removeMemberField,
      onSubmit: handleSubmit,
      submitLabel: 'Create group',
      membersHint: "You're added automatically — invite others by name.",
      showSubmitButton: false,
    );

    return buildScreen(
      title: widget.isFirstGroup ? 'Create your first group' : 'New group',
      showBackButton: !widget.isFirstGroup,
      body: Column(
        children: [
          Expanded(child: form),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ShadButton(
                    onPressed: isSubmitting ? null : handleSubmit,
                    child: isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create group'),
                  ),
                ),
                if (widget.isFirstGroup) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ShadButton.ghost(
                    onPressed: () => context.go('/'),
                    child: const Text('Skip for now'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
