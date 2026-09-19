import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:split/models/label.dart';
import 'package:split/providers/labels_provider.dart';
import 'package:split/repositories/label_repository.dart';

// See expenses_provider_test.dart: a real HTTP call yields to the event
// loop, which is what gives Riverpod's autoDispose timer a chance to run
// mid-mutation, unlike a bare microtask-only fake.
Future<T> _simulateNetworkCall<T>(T value) =>
    Future.delayed(const Duration(milliseconds: 1), () => value);

class _FakeLabelRepository implements LabelRepository {
  final List<Label> labels = [];
  bool failNextCreate = false;

  @override
  Future<List<Label>> fetchLabelsForGroup(String groupId) =>
      _simulateNetworkCall(List.of(labels));

  @override
  Future<Label> createLabel(CreateLabelInput input, String groupId) async {
    if (failNextCreate) throw Exception('boom');
    final label = Label(
      id: 'lbl-${labels.length + 1}',
      groupId: groupId,
      name: input.name,
      color: input.color,
      icon: input.icon,
    );
    labels.add(label);
    return _simulateNetworkCall(label);
  }
}

void main() {
  test('createLabel returns the created label and refreshes group labels '
      'from the server', () async {
    final repository = _FakeLabelRepository();
    final container = ProviderContainer(
      overrides: [labelRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    const groupId = 'group-1';

    final sub = container.listen(groupLabelsProvider(groupId), (_, _) {});
    addTearDown(sub.close);
    await container.read(groupLabelsProvider(groupId).future);

    final created = await container
        .read(groupLabelsProvider(groupId).notifier)
        .createLabel(
          CreateLabelInput(name: 'Food', color: const Color(0xFF4CB963)),
        );

    expect(created.name, 'Food');
    final state = container.read(groupLabelsProvider(groupId));
    expect(state.value, hasLength(1));
    expect(state.value!.single.name, 'Food');
  });

  test('createLabel rethrows on failure and leaves previous data in place', () async {
    final repository = _FakeLabelRepository();
    final container = ProviderContainer(
      overrides: [labelRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    const groupId = 'group-1';

    final sub = container.listen(groupLabelsProvider(groupId), (_, _) {});
    addTearDown(sub.close);
    final initial = await container.read(groupLabelsProvider(groupId).future);
    expect(initial, isEmpty);

    repository.failNextCreate = true;

    await expectLater(
      container
          .read(groupLabelsProvider(groupId).notifier)
          .createLabel(
            CreateLabelInput(name: 'Food', color: const Color(0xFF4CB963)),
          ),
      throwsA(isA<Exception>()),
    );

    final state = container.read(groupLabelsProvider(groupId));
    expect(state.value, isEmpty);
  });
}
