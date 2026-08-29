import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:split/models/transfer.dart';

abstract class TransferRepository {
  Future<List<Transfer>> fetchTransfers(String groupId);
}

class TransferRepositoryImpl implements TransferRepository {
  final http.Client _client;

  TransferRepositoryImpl(this._client);

  @override
  Future<List<Transfer>> fetchTransfers(String groupId) async {
    final response = await _client.get(Uri.parse('groups/$groupId/transfers'));
    final data = jsonDecode(response.body)['transfers'] as List<dynamic>;
    return data.map((transfer) => Transfer.fromJson(transfer)).toList();
  }
}
