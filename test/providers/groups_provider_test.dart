import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:split/models/group.dart';
import 'package:split/providers/analytics_provider.dart';
import 'package:split/providers/groups_provider.dart';
import 'package:split/repositories/group_repository.dart';

import '../fakes/fake_analytics_service.dart';

class _FakeGroupRepository implements GroupRepository {
  @override
  Future<List<Group>> fetchGroups() async => [];
  @override
  Future<List<Group>> fetchRecentGroups({required int limit}) async => [];
  @override
  Future<void> addGroup(CreateGroupInput group) async {}
  @override
  Future<void> removeGroup(String groupId) async {}
  @override
  Future<void> updateGroup(Group updatedGroup) async {}
  @override
  Future<void> addMemberToGroup(String groupId, String memberId) async {}
}

class _FailingGroupRepository extends _FakeGroupRepository {
  @override
  Future<void> addGroup(CreateGroupInput group) =>
      Future.error(Exception('boom'));
}

void main() {
  test(
    'addGroup captures group_created with the member count on success',
    () async {
      final analytics = FakeAnalyticsService();
      final container = ProviderContainer(
        overrides: [
          groupRepositoryProvider.overrideWithValue(_FakeGroupRepository()),
          analyticsServiceProvider.overrideWithValue(analytics),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(groupsProvider.notifier)
          .addGroup(
            const CreateGroupInput(name: 'Trip', memberIds: ['m1', 'm2']),
          );

      // Compared field-by-field rather than as a whole record: Dart record
      // equality delegates to the Map field's own `==`, which is identity-based
      // (Map doesn't override it), so two structurally-equal-but-distinct map
      // literals are never `==` — a bare `expect(captured, [(...)])` would fail
      // even when the captured event is correct.
      expect(analytics.captured, hasLength(1));
      expect(analytics.captured.single.$1, 'group_created');
      expect(analytics.captured.single.$2, {'memberCount': 2});
    },
  );

  test('addGroup does not capture an event when the mutation fails', () async {
    final analytics = FakeAnalyticsService();
    final container = ProviderContainer(
      overrides: [
        groupRepositoryProvider.overrideWithValue(_FailingGroupRepository()),
        analyticsServiceProvider.overrideWithValue(analytics),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container
          .read(groupsProvider.notifier)
          .addGroup(const CreateGroupInput(name: 'Trip', memberIds: ['m1'])),
      throwsA(isA<Exception>()),
    );
    expect(analytics.captured, isEmpty);
  });
}
