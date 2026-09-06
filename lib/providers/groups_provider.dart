import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split/models/group.dart';
import 'package:split/providers/current_member_provider.dart';
import 'package:split/providers/http_provider.dart';
import 'package:split/repositories/group_repository.dart';

const _recentGroupsLimit = 3;

class GroupsNotifier extends AsyncNotifier<List<Group>> {
  @override
  Future<List<Group>> build() {
    final repository = ref.watch(groupRepositoryProvider);
    if (repository == null) return Future.value(const []);
    return repository.fetchGroups();
  }

  Future<void> _mutateAndRefresh(Future<void> Function() mutation) async {
    final previous = state;

    final keepAlive = ref.keepAlive();
    try {
      final repository = ref.read(groupRepositoryProvider)!;
      await mutation();
      state = AsyncData(await repository.fetchGroups());
      ref.invalidate(recentGroupsProvider);
    } catch (error, stackTrace) {
      state = previous.hasValue ? previous : AsyncError(error, stackTrace);
      rethrow;
    } finally {
      keepAlive.close();
    }
  }

  Future<void> addGroup(CreateGroupInput group) async {
    await _mutateAndRefresh(
      () => ref.read(groupRepositoryProvider)!.addGroup(group),
    );
  }

  Future<void> removeGroup(String groupId) async {
    await _mutateAndRefresh(
      () => ref.read(groupRepositoryProvider)!.removeGroup(groupId),
    );
  }

  Future<void> editGroup({
    required Group group,
    required String name,
    required List<String> addedMemberIds,
  }) async {
    await _mutateAndRefresh(() async {
      final repository = ref.read(groupRepositoryProvider)!;
      if (name != group.name) {
        await repository.updateGroup(group.copyWith(name: name));
      }
      for (final memberId in addedMemberIds) {
        await repository.addMemberToGroup(group.id, memberId);
      }
    });
  }
}

/// Null while there's no signed-in [Member] yet (or not currently), e.g. in
/// the moment `currentMemberProvider` resolves to `null` on sign-out but
/// before the screens watching this have unmounted. Nothing on this path may
/// throw on a null [Member]: Riverpod flushes the whole provider graph from
/// inside `ProviderScope.build()`, before the widget tree gets to unmount
/// those screens, so a throw here escapes to the root of the app rather than
/// being contained — see the `main_test.dart` regression test.
final groupRepositoryProvider = Provider.autoDispose<GroupRepository?>((ref) {
  final member = ref.watch(currentMemberProvider).value;
  if (member == null) return null;

  final client = ref.watch(httpClientProvider);
  return GroupRepositoryImpl(client, member.id);
});

final groupsProvider =
    AsyncNotifierProvider.autoDispose<GroupsNotifier, List<Group>>(
      GroupsNotifier.new,
    );

class RecentGroupsNotifier extends AsyncNotifier<List<Group>> {
  @override
  Future<List<Group>> build() {
    final repository = ref.watch(groupRepositoryProvider);
    if (repository == null) return Future.value(const []);
    return repository.fetchRecentGroups(limit: _recentGroupsLimit);
  }
}

final recentGroupsProvider =
    AsyncNotifierProvider.autoDispose<RecentGroupsNotifier, List<Group>>(
      RecentGroupsNotifier.new,
    );
