import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split/models/group.dart';
import 'package:split/repositories/group_repository.dart';

class GroupsNotifier extends AsyncNotifier<List<Group>> {
  @override
  Future<List<Group>> build() {
    return ref.watch(groupRepositoryProvider).fetchGroups();
  }

  Future<void> _mutateAndRefresh(Future<void> Function() mutation) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(groupRepositoryProvider);
      await mutation();
      return await repository.fetchGroups();
    });
  }

  Future<void> addGroup(Group group) async {
    await _mutateAndRefresh(
      () => ref.read(groupRepositoryProvider).addGroup(group),
    );
  }

  Future<void> removeGroup(String groupId) async {
    await _mutateAndRefresh(
      () => ref.read(groupRepositoryProvider).removeGroup(groupId),
    );
  }

  Future<void> updateGroup(Group updatedGroup) async {
    await _mutateAndRefresh(
      () => ref.read(groupRepositoryProvider).updateGroup(updatedGroup),
    );
  }
}

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepositoryImpl();
});

final groupsProvider = AsyncNotifierProvider<GroupsNotifier, List<Group>>(
  GroupsNotifier.new,
);
