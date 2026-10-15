import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/expense.dart';
import '../../models/member.dart';
import '../../models/recurring_expense.dart';
import '../../providers/recurring_expenses_provider.dart';
import '../../theme/app_spacing.dart';
import '../../utils/formatting.dart';
import '../../utils/network_exception.dart';
import '../shared/async_error_text.dart';
import '../shared/sheet_content_spacer.dart';

/// Opens a read-only details sheet for [expense] — date, payer, shares and
/// how they were split — plus, when [Expense.isRecurring], the recurrence
/// description and a Pause/Resume action for its rule.
Future<void> showExpenseDetailsSheet(
  BuildContext context,
  String groupId,
  Expense expense,
  Member currentUser,
) async {
  await showShadSheet<void>(
    context: context,
    useRootNavigator: true,
    builder: (sheetContext) => _ExpenseDetailsSheetContent(
      groupId: groupId,
      expense: expense,
      currentUser: currentUser,
    ),
  );
}

/// The recurring section fetches lazily via [recurringExpensesProvider] and
/// renders its own loading/error states inline, so the rest of the sheet
/// (all of it already in memory on [expense]) never waits on that fetch.
class _ExpenseDetailsSheetContent extends ConsumerWidget {
  const _ExpenseDetailsSheetContent({
    required this.groupId,
    required this.expense,
    required this.currentUser,
  });

  final String groupId;
  final Expense expense;
  final Member currentUser;

  String _nameFor(Member member) =>
      member.id == currentUser.id ? 'You' : member.name;

  Future<void> _togglePause(
    BuildContext context,
    WidgetRef ref,
    RecurringExpense rule,
  ) async {
    try {
      await ref
          .read(recurringExpensesProvider(groupId).notifier)
          .setActive(rule.id, !rule.active);
    } catch (error) {
      if (!context.mounted) return;
      final errorMessage = error is NetworkException
          ? error.error.message
          : error.toString();
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('Could not update this expense'),
          description: Text(errorMessage),
        ),
      );
    }
  }

  Widget _buildRecurringSection(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final rulesAsync = ref.watch(recurringExpensesProvider(groupId));

    return rulesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: AsyncErrorText(error: error),
      ),
      data: (rules) {
        final rule = rules.firstWhereOrNull(
          (r) => r.id == expense.recurringExpenseId,
        );
        if (rule == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(
              'Could not find this recurring expense.',
              style: theme.textTheme.muted,
            ),
          );
        }
        final scheduleText = describeRecurrence(rule.frequency, rule.interval);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.md),
            Text(
              rule.active ? scheduleText : '$scheduleText (paused)',
              style: theme.textTheme.muted,
            ),
            const SizedBox(height: AppSpacing.md),
            ShadButton.outline(
              leading: HugeIcon(
                icon: rule.active
                    ? HugeIcons.strokeRoundedPause
                    : HugeIcons.strokeRoundedPlay,
                size: 16,
              ),
              onPressed: () => _togglePause(context, ref, rule),
              child: Text(rule.active ? 'Pause' : 'Resume'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    // Computed inside the sheet's own builder context, which sits on the
    // root navigator outside the screen's SafeArea — reading it from the
    // tile's context instead (above the SafeArea) always returns zero.
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final shareCount = expense.shares.length;

    return ShadSheet(
      useSafeArea: false,
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset),
      title: Text(expense.concept),
      description: Text(formatDate(expense.date)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          sheetContentSpacer,
          Text('Paid by ${_nameFor(expense.paidBy)}', style: theme.textTheme.p),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Split equally among $shareCount '
            '${shareCount == 1 ? 'person' : 'people'}',
            style: theme.textTheme.muted,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final share in expense.shares)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_nameFor(share.member), style: theme.textTheme.p),
                  Text(formatAmount(share.amount), style: theme.textTheme.p),
                ],
              ),
            ),
          if (expense.isRecurring) _buildRecurringSection(context, ref),
        ],
      ),
    );
  }
}
