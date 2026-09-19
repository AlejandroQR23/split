import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split/models/label.dart';
import 'package:split/providers/current_member_provider.dart';
import 'package:split/providers/http_provider.dart';
import 'package:split/repositories/label_repository.dart';

class GroupLabelsNotifier extends AsyncNotifier<List<Label>> {
  GroupLabelsNotifier(this.groupId);

  final String groupId;

  @override
  Future<List<Label>> build() {
    final repository = ref.watch(labelRepositoryProvider);
    if (repository == null) return Future.value(const []);
    return repository.fetchLabelsForGroup(groupId);
  }

  Future<Label> createLabel(CreateLabelInput input) async {
    final previous = state;

    final keepAlive = ref.keepAlive();
    try {
      final repository = ref.read(labelRepositoryProvider)!;
      final label = await repository.createLabel(input, groupId);
      state = AsyncData(await repository.fetchLabelsForGroup(groupId));
      return label;
    } catch (error, stackTrace) {
      state = previous.hasValue ? previous : AsyncError(error, stackTrace);
      rethrow;
    } finally {
      keepAlive.close();
    }
  }
}

final labelRepositoryProvider = Provider.autoDispose<LabelRepository?>((ref) {
  final member = ref.watch(currentMemberProvider).value;
  if (member == null) return null;

  final client = ref.watch(httpClientProvider);
  return LabelRepositoryImpl(client);
});

final groupLabelsProvider = AsyncNotifierProvider.autoDispose
    .family<GroupLabelsNotifier, List<Label>, String>(
      (groupId) => GroupLabelsNotifier(groupId),
    );
