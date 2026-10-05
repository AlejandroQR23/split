import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:split/repositories/recurring_expense_repository.dart';

void main() {
  group('fetchRecurringExpenses', () {
    test('GETs groups/{groupId}/recurring-expenses and parses the list', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, 'groups/grp_01h/recurring-expenses');
        return http.Response(
          jsonEncode({
            'recurringExpenses': [
              {
                'id': 'rec_01h',
                'groupId': 'grp_01h',
                'concept': 'Rent',
                'amount': 1000.0,
                'paidBy': {'id': 'mem_01h', 'name': 'Alice', 'isGhost': false},
                'shares': [
                  {
                    'member': {
                      'id': 'mem_01h',
                      'name': 'Alice',
                      'isGhost': false,
                    },
                    'amount': 1000.0,
                  },
                ],
                'frequency': 'monthly',
                'interval': 1,
                'anchorDate': '2026-09-01T00:00:00Z',
                'active': true,
              },
            ],
          }),
          200,
        );
      });
      final repository = RecurringExpenseRepositoryImpl(client);

      final rules = await repository.fetchRecurringExpenses('grp_01h');

      expect(rules, hasLength(1));
      expect(rules.single.concept, 'Rent');
    });
  });

  group('setActive', () {
    test('PATCHes recurring-expenses/{id} with the active flag', () async {
      final client = MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.path, 'recurring-expenses/rec_01h');
        expect(jsonDecode(request.body), {'active': false});
        return http.Response('{}', 200);
      });
      final repository = RecurringExpenseRepositoryImpl(client);

      await repository.setActive('rec_01h', false);
    });
  });
}
