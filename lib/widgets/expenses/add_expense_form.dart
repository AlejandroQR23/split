import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/group.dart';
import '../../models/member.dart';
import '../../theme/app_spacing.dart';
import '../shared/member_selector.dart';

/// Form body for [AddExpenseScreen]: group/concept/amount fields plus the
/// "Paid by" and "Split between" member pickers.
class AddExpenseForm extends StatelessWidget {
  const AddExpenseForm({
    super.key,
    required this.groups,
    required this.groupId,
    required this.selectedGroupId,
    required this.payerId,
    required this.splitMemberIds,
    required this.submitted,
    required this.isSubmitting,
    required this.formKey,
    required this.findGroup,
    required this.onGroupChanged,
    required this.onPayerChanged,
    required this.onSplitMemberIdsChanged,
    required this.onSubmit,
  });

  final List<Group> groups;
  final String? groupId;
  final String? selectedGroupId;
  final String? payerId;
  final Set<String> splitMemberIds;
  final bool submitted;
  final bool isSubmitting;
  final GlobalKey<ShadFormState> formKey;
  final Group? Function(List<Group> groups, String? id) findGroup;
  final ValueChanged<String?> onGroupChanged;
  final ValueChanged<String?> onPayerChanged;
  final ValueChanged<Set<String>> onSplitMemberIdsChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    final groupLocked = groupId != null;
    final group = findGroup(groups, selectedGroupId);
    final members = group?.members ?? const <Member>[];

    final fieldLabelStyle = theme.textTheme.muted.copyWith(
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.foreground,
    );
    final fieldErrorStyle = theme.textTheme.muted.copyWith(
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.destructive,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      children: [
        ShadForm(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) => ShadSelectFormField<String>(
                  id: 'groupId',
                  label: const Text('Group'),
                  enabled: !groupLocked,
                  initialValue: selectedGroupId,
                  minWidth: constraints.maxWidth,
                  placeholder: const Text('Select a group'),
                  selectedOptionBuilder: (context, value) =>
                      Text(findGroup(groups, value)?.name ?? value),
                  options: [
                    for (final g in groups)
                      ShadOption(value: g.id, child: Text(g.name)),
                  ],
                  onChanged: onGroupChanged,
                  validator: (v) {
                    if (v == null) return 'Please select a group';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ShadInputFormField(
                id: 'concept',
                label: const Text('Concept'),
                placeholder: const Text('Dinner, groceries, taxi…'),
                validator: (v) {
                  if (v.trim().isEmpty) {
                    return 'Enter what this expense was for';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              ShadInputFormField(
                id: 'amount',
                label: const Text('Amount'),
                placeholder: const Text('0.00'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  final parsed = double.tryParse(v);
                  if (parsed == null || parsed <= 0) {
                    return 'Enter an amount greater than 0';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Paid by', style: fieldLabelStyle),
        const SizedBox(height: AppSpacing.sm),
        if (members.isEmpty)
          Text('Select a group first', style: theme.textTheme.muted)
        else
          MemberSelector(
            members: members,
            multiSelect: false,
            selectedIds: payerId == null ? const {} : {payerId!},
            onChanged: (ids) => onPayerChanged(ids.isEmpty ? null : ids.first),
          ),
        if (submitted && payerId == null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text('Select who paid', style: fieldErrorStyle),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text('Split between', style: fieldLabelStyle),
        const SizedBox(height: AppSpacing.sm),
        if (members.isEmpty)
          Text('Select a group first', style: theme.textTheme.muted)
        else
          MemberSelector(
            members: members,
            multiSelect: true,
            selectedIds: splitMemberIds,
            onChanged: onSplitMemberIdsChanged,
          ),
        if (submitted && splitMemberIds.isEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text('Select at least one person', style: fieldErrorStyle),
        ],
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: ShadButton(
            onPressed: isSubmitting ? null : onSubmit,
            child: isSubmitting
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primaryForeground,
                    ),
                  )
                : const Text('Add expense'),
          ),
        ),
      ],
    );
  }
}
