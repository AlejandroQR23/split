import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;

import 'package:split/api/guest_http_client.dart';
import 'package:split/models/expense.dart';
import 'package:split/models/group.dart';
import 'package:split/models/invite.dart';
import 'package:split/models/transfer.dart';
import 'package:split/providers/http_provider.dart';
import 'package:split/repositories/guest_groups_repository.dart';
import 'package:split/repositories/invite_repository.dart';
import 'package:split/repositories/transfer_repository.dart';

/// Claiming/generating invites always goes through the authenticated
/// session's own `HttpClient` — see [InviteRepository.claimInvite]'s doc
/// comment for why.
final inviteRepositoryProvider = Provider<InviteRepository>((ref) {
  final client = ref.watch(httpClientProvider);
  return InviteRepositoryImpl(client);
});

/// Set right before a fresh sign-up initiated from `InviteScreen`, read
/// once by `currentMemberProvider` the moment that sign-up's auth state
/// resolves — see that provider's doc comment for why this beats a plain
/// `GET /members/me` race. Cleared by `currentMemberProvider` itself once
/// consumed.
final pendingInviteTokenProvider = StateProvider<String?>((ref) => null);

/// One [GuestHttpClient] per invite token — every guest fetch for the same
/// token shares one client instance.
final guestHttpClientProvider = Provider.autoDispose.family<http.Client, String>(
  (ref, token) {
    final client = GuestHttpClient(http.Client(), token);
    ref.onDispose(client.close);
    return client;
  },
);

final invitePreviewProvider = FutureProvider.autoDispose
    .family<InvitePreview, String>((ref, token) {
      return ref.watch(inviteRepositoryProvider).fetchPreview(token);
    }, retry: (_, _) => null);

final guestGroupsRepositoryProvider = Provider.autoDispose
    .family<GuestGroupsRepository, String>((ref, token) {
      final client = ref.watch(guestHttpClientProvider(token));
      return GuestGroupsRepositoryImpl(client);
    });

final inviteGroupsProvider = FutureProvider.autoDispose
    .family<List<Group>, String>((ref, token) {
      return ref.watch(guestGroupsRepositoryProvider(token)).fetchGroups();
    }, retry: (_, _) => null);

/// Keys a group-scoped guest fetch by both the invite token (which guest
/// client to use) and the group id (which group).
typedef InviteGroupKey = ({String token, String groupId});

final inviteGroupTransfersProvider = FutureProvider.autoDispose
    .family<List<Transfer>, InviteGroupKey>((ref, key) {
      final client = ref.watch(guestHttpClientProvider(key.token));
      return TransferRepositoryImpl(client).fetchTransfers(key.groupId);
    }, retry: (_, _) => null);

/// Not built on [ExpenseRepositoryImpl] — its constructor takes a viewer
/// id that `fetchExpensesForGroup` never uses, and threading a meaningless
/// value through it just to reuse one method is worse than this five-line
/// fetch.
final inviteGroupExpensesProvider = FutureProvider.autoDispose
    .family<List<Expense>, InviteGroupKey>((ref, key) async {
      final client = ref.watch(guestHttpClientProvider(key.token));
      final response = await client.get(
        Uri.parse('groups/${key.groupId}/expenses'),
      );
      final data = jsonDecode(response.body)['expenses'] as List<dynamic>;
      return data.map((json) => Expense.fromJson(json)).toList();
    }, retry: (_, _) => null);
