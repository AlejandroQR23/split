import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:split/models/label.dart';

abstract class LabelRepository {
  Future<List<Label>> fetchLabelsForGroup(String groupId);
  Future<Label> createLabel(CreateLabelInput input, String groupId);
}

class LabelRepositoryImpl implements LabelRepository {
  final http.Client _client;

  LabelRepositoryImpl(this._client);

  @override
  Future<List<Label>> fetchLabelsForGroup(String groupId) async {
    final response = await _client.get(Uri.parse('groups/$groupId/labels'));

    final data = jsonDecode(response.body)['labels'] as List<dynamic>;

    return data.map((label) => Label.fromJson(label)).toList();
  }

  @override
  Future<Label> createLabel(CreateLabelInput input, String groupId) async {
    final response = await _client.post(
      Uri.parse('groups/$groupId/labels'),
      body: jsonEncode(input.toJson()),
    );

    return Label.fromJson(jsonDecode(response.body));
  }
}
