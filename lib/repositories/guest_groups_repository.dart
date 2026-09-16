import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:split/models/group.dart';

/// Read-only group listing for an invite-token identity. Deliberately
/// narrower than [GroupRepository]: a guest browsing via an invite link
/// never creates, renames, or leaves a group — the backend rejects
/// invite-token writes with `403 ghost_read_only` regardless, but this
/// interface doesn't even offer the temptation.
abstract class GuestGroupsRepository {
  Future<List<Group>> fetchGroups();
}

class GuestGroupsRepositoryImpl implements GuestGroupsRepository {
  GuestGroupsRepositoryImpl(this._client);

  final http.Client _client;

  @override
  Future<List<Group>> fetchGroups() async {
    final response = await _client.get(Uri.parse('groups'));
    final data = jsonDecode(response.body)['groups'] as List<dynamic>;

    return data.map((group) => Group.fromJson(group)).toList();
  }
}
