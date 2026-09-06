import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:split/models/member.dart';

abstract class MemberRepository {
  Future<Member> addMember(String name);

  /// Get-or-create for the signed-in Firebase identity — provisions this
  /// account's `Member` row on first call.
  Future<Member> fetchMe();

  Future<Member> updateName(String memberId, String name);
}

class MemberRepositoryImpl implements MemberRepository {
  final http.Client _client;

  MemberRepositoryImpl(this._client);

  @override
  Future<Member> addMember(String name) async {
    final response = await _client.post(
      Uri.parse('members'),
      body: jsonEncode({'name': name}),
    );

    return Member.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<Member> fetchMe() async {
    final response = await _client.get(Uri.parse('members/me'));

    return Member.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<Member> updateName(String memberId, String name) async {
    final response = await _client.patch(
      Uri.parse('members/$memberId'),
      body: jsonEncode({'name': name}),
    );

    return Member.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
