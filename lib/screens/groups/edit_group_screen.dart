import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../providers/groups_provider.dart';
import '../../providers/member_provider.dart';
import '../../widgets/groups/group_form.dart';
import '../../widgets/shared/async_error_text.dart';
import 'group_form_screen.dart';

/// Edit an existing group: rename it and/or invite additional members.
/// Removing an existing member isn't supported here — the backend blocks
/// that when the member has an open balance, and there's no force-remove.
class EditGroupScreen extends ConsumerStatefulWidget {
  final String groupId;

  const EditGroupScreen({super.key, required this.groupId});

  @override
  ConsumerState<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends GroupFormScreenState<EditGroupScreen> {
  @override
  String get errorToastTitle => 'Could not save group';

  @override
  Future<void> onSubmit(String name, List<String> newMemberNames) async {
    final memberRepository = ref.read(memberRepositoryProvider);
    final addedMemberIds = [
      for (final memberName in newMemberNames)
        (await memberRepository.addMember(memberName)).id,
    ];

    final groups = await ref.read(groupsProvider.future);
    final group = groups.firstWhere((g) => g.id == widget.groupId);

    await ref
        .read(groupsProvider.notifier)
        .editGroup(group: group, name: name, addedMemberIds: addedMemberIds);

    if (!mounted) return;
    ShadToaster.of(context).show(const ShadToast(title: Text('Group updated')));
    context.pop();
  }

  Widget _skeletonSheet(BuildContext context, Widget child) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return ShadSheet(
      useSafeArea: false,
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset),
      title: const Text('Edit group'),
      child: SizedBox(height: 160, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupsResponse = ref.watch(groupsProvider);
    final theme = ShadTheme.of(context);
    final loading = Center(
      child: CircularProgressIndicator(color: theme.colorScheme.primary),
    );

    return groupsResponse.when(
      skipError: true,
      loading: () => _skeletonSheet(context, loading),
      error: (error, stackTrace) =>
          _skeletonSheet(context, AsyncErrorText(error: error)),
      data: (groups) {
        final group = groups.where((g) => g.id == widget.groupId).firstOrNull;
        if (group == null) {
          return _skeletonSheet(
            context,
            const AsyncErrorText(error: 'Group not found'),
          );
        }

        return buildSheet(
          title: 'Edit group',
          form: GroupForm(
            formKey: formKey,
            memberControllers: memberControllers,
            onAddMemberField: addMemberField,
            onRemoveMemberField: removeMemberField,
            membersHint: 'Invite more people by name.',
            initialName: group.name,
            existingMembers: group.members,
          ),
          submitLabel: 'Save changes',
        );
      },
    );
  }
}
