import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:split/models/transfer.dart';
import 'package:split/providers/http_provider.dart';
import 'package:split/repositories/transfer_repository.dart';

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  final client = ref.watch(httpClientProvider);

  return TransferRepositoryImpl(client);
});

class GroupTransfersNotifier extends AsyncNotifier<List<Transfer>> {
  GroupTransfersNotifier(this.groupId);

  final String groupId;

  @override
  Future<List<Transfer>> build() {
    return ref.watch(transferRepositoryProvider).fetchTransfers(groupId);
  }
}

final groupTransfersProvider =
    AsyncNotifierProvider.family<
      GroupTransfersNotifier,
      List<Transfer>,
      String
    >((groupId) => GroupTransfersNotifier(groupId));
