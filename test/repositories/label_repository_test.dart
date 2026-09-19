import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:split/models/label.dart';
import 'package:split/repositories/label_repository.dart';

// http.Response defaults to latin1 when no charset is given, which can't
// encode the emoji in these fixtures — force utf-8 like the real backend
// does.
const _jsonUtf8Headers = {'content-type': 'application/json; charset=utf-8'};

void main() {
  group('createLabel', () {
    test('POSTs the label body to groups/{groupId}/labels', () async {
      final inner = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, 'groups/grp_01h/labels');
        expect(jsonDecode(request.body), {
          'name': 'Food',
          'color': '#4CB963',
          'icon': '🍕',
        });
        return http.Response(
          jsonEncode({
            'id': 'lbl_01h',
            'groupId': 'grp_01h',
            'name': 'Food',
            'color': '#4CB963',
            'icon': '🍕',
          }),
          201,
          headers: _jsonUtf8Headers,
        );
      });
      final repository = LabelRepositoryImpl(inner);

      final label = await repository.createLabel(
        CreateLabelInput(
          name: 'Food',
          color: const Color(0xFF4CB963),
          icon: '🍕',
        ),
        'grp_01h',
      );

      expect(label.id, 'lbl_01h');
      expect(label.name, 'Food');
    });
  });

  group('fetchLabelsForGroup', () {
    test('GETs groups/{groupId}/labels and parses the envelope', () async {
      final inner = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, 'groups/grp_01h/labels');
        return http.Response(
          jsonEncode({
            'labels': [
              {
                'id': 'lbl_01h',
                'groupId': 'grp_01h',
                'name': 'Food',
                'color': '#4CB963',
                'icon': '🍕',
              },
            ],
          }),
          200,
          headers: _jsonUtf8Headers,
        );
      });
      final repository = LabelRepositoryImpl(inner);

      final labels = await repository.fetchLabelsForGroup('grp_01h');

      expect(labels, hasLength(1));
      expect(labels.first.name, 'Food');
    });
  });
}
