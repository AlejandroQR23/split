import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:split/models/settlement.dart';
import 'package:split/providers/current_member_provider.dart';
import 'package:split/providers/http_provider.dart';
import 'package:split/repositories/settlement_repository.dart';

final settlementRepositoryProvider = Provider<SettlementRepository>((ref) {
  final client = ref.watch(httpClientProvider);
  final user = ref.watch(requireCurrentMemberProvider);

  return SettlementRepositoryImpl(client, user.id);
});

class AllSettlementsNotifier extends AsyncNotifier<List<Settlement>> {
  @override
  Future<List<Settlement>> build() {
    return ref.watch(settlementRepositoryProvider).fetchSettlements();
  }
}

final allSettlementsProvider =
    AsyncNotifierProvider<AllSettlementsNotifier, List<Settlement>>(
      AllSettlementsNotifier.new,
    );

class GroupSettlementsNotifier extends AsyncNotifier<List<Settlement>> {
  GroupSettlementsNotifier(this.groupId);

  final String groupId;

  @override
  Future<List<Settlement>> build() {
    return ref
        .watch(settlementRepositoryProvider)
        .fetchGroupSettlements(groupId);
  }
}

final groupSettlementsProvider =
    AsyncNotifierProvider.family<
      GroupSettlementsNotifier,
      List<Settlement>,
      String
    >((groupId) => GroupSettlementsNotifier(groupId));
