import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/group.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/groups_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/expenses/add_expense_form.dart';
import '../../widgets/navigation/screen_header.dart';

/// Form for logging a new expense. When [groupId] is provided (opened from
/// a group's own balance card) the group is fixed; otherwise the form opens
/// with a group picker (opened from the Home balance card).
class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key, this.groupId});

  final String? groupId;

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<ShadFormState>();

  String? _selectedGroupId;
  String? _payerId;
  final Set<String> _splitMemberIds = {};
  bool _submitted = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedGroupId = widget.groupId;
  }

  Group? _findGroup(List<Group> groups, String? id) {
    if (id == null) return null;
    for (final group in groups) {
      if (group.id == id) return group;
    }
    return null;
  }

  void _onGroupChanged(String? groupId) {
    setState(() {
      _selectedGroupId = groupId;
      _payerId = null;
      _splitMemberIds.clear();
    });
  }

  Future<void> _handleSubmit(List<Group> groups) async {
    setState(() => _submitted = true);

    final formOk = _formKey.currentState?.saveAndValidate() ?? false;
    final group = _findGroup(groups, _selectedGroupId);
    final payerId = _payerId;

    if (!formOk ||
        group == null ||
        payerId == null ||
        _splitMemberIds.isEmpty) {
      return;
    }

    final formValue = _formKey.currentState!.value;
    final concept = formValue['concept'] as String;
    final amount = double.parse(formValue['amount'] as String);
    final payer = group.members.firstWhere((m) => m.id == payerId);
    final splitMembers = group.members
        .where((m) => _splitMemberIds.contains(m.id))
        .toList();

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(expensesProvider(group.id).notifier)
          .addEvenExpense(
            concept: concept,
            amount: amount,
            paidBy: payer,
            splitBetween: splitMembers,
          );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('Could not save expense'),
          description: Text('$error'),
        ),
      );
      return;
    }

    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final groupsResponse = ref.watch(groupsProvider);
    final theme = ShadTheme.of(context);

    Widget body;
    if (groupsResponse is AsyncError) {
      body = Center(
        child: Text(
          'Error: ${groupsResponse.error}',
          style: theme.textTheme.p.copyWith(
            color: theme.colorScheme.destructive,
          ),
        ),
      );
    } else if (groupsResponse is! AsyncData<List<Group>>) {
      body = Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    } else {
      body = AddExpenseForm(
        groups: groupsResponse.value,
        groupId: widget.groupId,
        selectedGroupId: _selectedGroupId,
        payerId: _payerId,
        splitMemberIds: _splitMemberIds,
        submitted: _submitted,
        isSubmitting: _isSubmitting,
        formKey: _formKey,
        findGroup: _findGroup,
        onGroupChanged: _onGroupChanged,
        onPayerChanged: (value) => setState(() => _payerId = value),
        onSplitMemberIdsChanged: (ids) => setState(() {
          _splitMemberIds
            ..clear()
            ..addAll(ids);
        }),
        onSubmit: () => _handleSubmit(groupsResponse.value),
      );
    }

    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.background),
      child: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Add expense'),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
