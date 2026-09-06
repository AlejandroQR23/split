import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:split/models/settlement.dart';
import 'package:split/providers/current_member_provider.dart';
import 'package:split/providers/http_provider.dart';
import 'package:split/repositories/settlement_repository.dart';

final settlementRepositoryProvider =
    Provider.autoDispose<SettlementRepository?>((ref) {
      final member = ref.watch(currentMemberProvider).value;
      if (member == null) return null;

      final client = ref.watch(httpClientProvider);
      return SettlementRepositoryImpl(client, member.id);
    });

class AllSettlementsNotifier extends AsyncNotifier<List<Settlement>> {
  @override
  Future<List<Settlement>> build() {
    final repository = ref.watch(settlementRepositoryProvider);
    if (repository == null) return Future.value(const []);
    return repository.fetchSettlements();
  }
}

final allSettlementsProvider =
    AsyncNotifierProvider.autoDispose<AllSettlementsNotifier, List<Settlement>>(
      AllSettlementsNotifier.new,
    );

class GroupSettlementsNotifier extends AsyncNotifier<List<Settlement>> {
  GroupSettlementsNotifier(this.groupId);

  final String groupId;

  @override
  Future<List<Settlement>> build() {
    final repository = ref.watch(settlementRepositoryProvider);
    if (repository == null) return Future.value(const []);
    return repository.fetchGroupSettlements(groupId);
  }
}

final groupSettlementsProvider = AsyncNotifierProvider.autoDispose
    .family<GroupSettlementsNotifier, List<Settlement>, String>(
      (groupId) => GroupSettlementsNotifier(groupId),
    );
