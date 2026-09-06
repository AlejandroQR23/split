import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:split/models/expense.dart';
import 'package:split/repositories/expense_repository.dart';

void main() {
  group('addPayment', () {
    test('POSTs the payment body to groups/{groupId}/payments', () async {
      final inner = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, 'groups/grp_01h/payments');
        expect(jsonDecode(request.body), {
          'fromMemberId': 'mem_02h',
          'toMemberId': 'mem_01h',
          'amount': 20.0,
          'date': '2026-09-06T10:00:00.000Z',
        });
        return http.Response(
          jsonEncode({
            'id': 'exp_pay_01h',
            'groupId': 'grp_01h',
            'concept': 'Settle up',
            'amount': 20.0,
            'paidBy': {'id': 'mem_02h', 'name': 'Sam Lee'},
            'shares': [
              {
                'member': {'id': 'mem_01h', 'name': 'Alex Rivera'},
                'amount': 20.0,
              },
            ],
            'date': '2026-09-06T10:00:00.000Z',
            'type': 'payment',
          }),
          201,
        );
      });
      final repository = ExpenseRepositoryImpl(inner, 'mem_02h');

      await repository.addPayment(
        CreatePaymentInput(
          fromMemberId: 'mem_02h',
          toMemberId: 'mem_01h',
          amount: 20.0,
          date: DateTime.utc(2026, 9, 6, 10),
        ),
        'grp_01h',
      );
    });
  });
}
