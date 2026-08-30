import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/group.dart';
import '../../providers/groups_provider.dart';
import '../../providers/member_provider.dart';
import '../../widgets/groups/group_form.dart';
import 'group_form_screen.dart';

/// Form for creating a new group: a name plus any number of member names to
/// invite. Each name is created as a new [Member] via the member repository
/// before the group itself is submitted with the resulting member ids.
class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

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
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return buildScreen(
      title: 'New group',
      body: GroupForm(
        formKey: formKey,
        memberControllers: memberControllers,
        isSubmitting: isSubmitting,
        onAddMemberField: addMemberField,
        onRemoveMemberField: removeMemberField,
        onSubmit: handleSubmit,
        submitLabel: 'Create group',
        membersHint: "You're added automatically — invite others by name.",
      ),
    );
  }
}
