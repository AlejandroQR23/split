import 'package:split/data/mock_groups.dart';
import 'package:split/models/group.dart';

final delayDuration = const Duration(seconds: 3);

abstract class GroupRepository {
  Future<List<Group>> fetchGroups();
  Future<void> addGroup(Group group);
  Future<void> removeGroup(String groupId);
  Future<void> updateGroup(Group updatedGroup);
}

class GroupRepositoryImpl implements GroupRepository {
  final List<Group> _groups = List.of(mockGroups);

  @override
  Future<List<Group>> fetchGroups() async {
    await Future.delayed(delayDuration);
    return List.of(_groups);
  }

  @override
  Future<void> addGroup(Group group) async {
    await Future.delayed(delayDuration);
    _groups.add(group);
  }

  @override
  Future<void> removeGroup(String groupId) async {
    await Future.delayed(delayDuration);
    _groups.removeWhere((group) => group.id == groupId);
  }

  @override
  Future<void> updateGroup(Group updatedGroup) async {
    await Future.delayed(delayDuration);
    final index = _groups.indexWhere((group) => group.id == updatedGroup.id);
    if (index != -1) {
      _groups[index] = updatedGroup;
    }
  }
}
