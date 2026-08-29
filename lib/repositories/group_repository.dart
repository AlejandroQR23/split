import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:split/models/group.dart';

final delayDuration = const Duration(seconds: 2);

abstract class GroupRepository {
  Future<List<Group>> fetchGroups();
  Future<List<Group>> fetchRecentGroups({required int limit});
  Future<void> addGroup(CreateGroupInput group);
  Future<void> removeGroup(String groupId);
  Future<void> updateGroup(Group updatedGroup);
}

class GroupRepositoryImpl implements GroupRepository {
  final http.Client _client;
  final String _userId;

  GroupRepositoryImpl(this._client, this._userId);

  @override
  Future<List<Group>> fetchGroups() async {
    final response = await _client.get(Uri.parse('groups'));
    final data = jsonDecode(response.body)['groups'] as List<dynamic>;

    return data.map((group) => Group.fromJson(group)).toList();
  }

  @override
  Future<List<Group>> fetchRecentGroups({required int limit}) async {
    final response = await _client.get(
      Uri.parse(
        'members/$_userId/groups',
      ).replace(queryParameters: {'limit': limit.toString()}),
    );
    final data = jsonDecode(response.body)['groups'] as List<dynamic>;

    return data.map((group) => Group.fromJson(group)).toList();
  }

  @override
  Future<void> addGroup(CreateGroupInput group) async {
    await _client.post(Uri.parse('groups'), body: jsonEncode(group.toJson()));
  }

  @override
  Future<void> removeGroup(String groupId) async {
    await _client.delete(Uri.parse('groups/$groupId'));
  }

  @override
  Future<void> updateGroup(Group updatedGroup) async {
    await _client.patch(
      Uri.parse('groups/${updatedGroup.id}'),
      body: jsonEncode({'name': updatedGroup.name}),
    );
  }
}
