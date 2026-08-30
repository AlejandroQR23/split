import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:split/models/member.dart';

abstract class MemberRepository {
  Future<Member> addMember(String name);
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
}
