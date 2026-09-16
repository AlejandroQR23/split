import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:split/providers/invite_provider.dart';

void main() {
  setUpAll(() {
    dotenv.loadFromString(envString: 'API_URL=https://api.split.example.com');
  });

  test('pendingInviteTokenProvider defaults to null', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(pendingInviteTokenProvider), isNull);
  });

  test('guestGroupsRepositoryProvider fetches through the guest client for that token', () async {
    http.Request? capturedRequest;
    final container = ProviderContainer(
      overrides: [
        guestHttpClientProvider('inv_abc123').overrideWithValue(
          _fakeGuestClient((request) async {
            capturedRequest = request;
            return http.Response(jsonEncode({'groups': []}), 200);
          }),
        ),
      ],
    );
    addTearDown(container.dispose);

    final groups = await container
        .read(guestGroupsRepositoryProvider('inv_abc123'))
        .fetchGroups();

    expect(groups, isEmpty);
    expect(capturedRequest!.url.path, 'groups');
  });

  test('inviteGroupExpensesProvider fetches a group\'s expenses via the guest client', () async {
    final container = ProviderContainer(
      overrides: [
        guestHttpClientProvider('inv_abc123').overrideWithValue(
          _fakeGuestClient((request) async {
            expect(request.url.path, 'groups/grp_01h/expenses');
            return http.Response(jsonEncode({'expenses': []}), 200);
          }),
        ),
      ],
    );
    addTearDown(container.dispose);

    final expenses = await container.read(
      inviteGroupExpensesProvider((token: 'inv_abc123', groupId: 'grp_01h')).future,
    );

    expect(expenses, isEmpty);
  });

  test('inviteGroupTransfersProvider fetches a group\'s transfers via the guest client', () async {
    final container = ProviderContainer(
      overrides: [
        guestHttpClientProvider('inv_abc123').overrideWithValue(
          _fakeGuestClient((request) async {
            expect(request.url.path, 'groups/grp_01h/transfers');
            return http.Response(jsonEncode({'transfers': []}), 200);
          }),
        ),
      ],
    );
    addTearDown(container.dispose);

    final transfers = await container.read(
      inviteGroupTransfersProvider((token: 'inv_abc123', groupId: 'grp_01h')).future,
    );

    expect(transfers, isEmpty);
  });
}

http.Client _fakeGuestClient(
  Future<http.Response> Function(http.Request) handler,
) => MockClient(handler);
