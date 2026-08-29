import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split/models/group.dart';
import 'package:split/providers/current_user_provider.dart';
import 'package:split/providers/http_provider.dart';
import 'package:split/repositories/group_repository.dart';

const _recentGroupsLimit = 3;

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

  Future<void> addGroup(CreateGroupInput group) async {
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
  final client = ref.watch(httpClientProvider);
  final user = ref.watch(currentUserProvider);

  return GroupRepositoryImpl(client, user.id);
});

final groupsProvider = AsyncNotifierProvider<GroupsNotifier, List<Group>>(
  GroupsNotifier.new,
);

class RecentGroupsNotifier extends AsyncNotifier<List<Group>> {
  @override
  Future<List<Group>> build() {
    return ref
        .watch(groupRepositoryProvider)
        .fetchRecentGroups(limit: _recentGroupsLimit);
  }
}

final recentGroupsProvider =
    AsyncNotifierProvider<RecentGroupsNotifier, List<Group>>(
      RecentGroupsNotifier.new,
    );
