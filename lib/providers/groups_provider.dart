import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split/models/group.dart';
import 'package:split/repositories/group_repository.dart';

class GroupsNotifier extends AsyncNotifier<List<Group>> {
  @override
  Future<List<Group>> build() {
    return ref.watch(groupRepositoryProvider).fetchGroups();
  }

  Future<void> _mutateAndRefresh(Future<void> Function() mutation) async {
    final previous = state;
    try {
      final repository = ref.read(groupRepositoryProvider);
      await mutation();
      state = AsyncData(await repository.fetchGroups());
    } catch (error, stackTrace) {
      state = previous.hasValue ? previous : AsyncError(error, stackTrace);
      rethrow;
    }
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
