import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:split/models/settlement.dart';

abstract class SettlementRepository {
  Future<List<Settlement>> fetchSettlements();
  Future<List<Settlement>> fetchGroupSettlements(String groupId);
}

class SettlementRepositoryImpl implements SettlementRepository {
  final http.Client _client;
  final String _userId;

  SettlementRepositoryImpl(this._client, this._userId);

  @override
  Future<List<Settlement>> fetchSettlements() async {
    final response = await _client.get(
      Uri.parse('members/$_userId/settlements'),
    );
    final data = jsonDecode(response.body)['settlements'] as List<dynamic>;

    return data.map((settlement) => Settlement.fromJson(settlement)).toList();
  }

  @override
  Future<List<Settlement>> fetchGroupSettlements(String groupId) async {
    final response = await _client.get(
      Uri.parse('groups/$groupId/settlements'),
    );
    final data = jsonDecode(response.body)['settlements'] as List<dynamic>;

    return data.map((settlement) => Settlement.fromJson(settlement)).toList();
  }
}
