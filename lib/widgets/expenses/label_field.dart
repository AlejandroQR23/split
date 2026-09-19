import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/label.dart';
import '../../providers/labels_provider.dart';
import '../shared/async_error_text.dart';
import 'create_label_sheet.dart';
import 'label_selector.dart';

/// Self-contained "Label" section for the add-expense form: watches this
/// group's labels itself (rather than threading the [AsyncValue] through
/// [AddExpenseForm]'s constructor) and opens the creation sheet.
class LabelField extends ConsumerWidget {
  const LabelField({
    super.key,
    required this.groupId,
    required this.selectedLabelId,
    required this.onChanged,
  });

  final String groupId;
  final String? selectedLabelId;
  final ValueChanged<String?> onChanged;

  Future<void> _handleCreateNew(BuildContext context) async {
    final label = await showCreateLabelSheet(context, groupId);
    if (label != null) onChanged(label.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final labelsResponse = ref.watch(groupLabelsProvider(groupId));

    return switch (labelsResponse) {
      AsyncError(:final error) => AsyncErrorText(error: error),
      AsyncData<List<Label>>(:final value) => LabelSelector(
        labels: value,
        selectedLabelId: selectedLabelId,
        onChanged: onChanged,
        onCreateNew: () => _handleCreateNew(context),
      ),
      _ => Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    };
  }
}
