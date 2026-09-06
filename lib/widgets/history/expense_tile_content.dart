import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/expense.dart';
import '../../models/member.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/formatting.dart';
import '../shared/avatar.dart';

/// The shared card layout for one [Expense] row in a history/activity list:
/// an avatar (or a money-exchange icon for a payment), a title/subtitle, and
/// the amount. Payment-vs-regular-expense presentation (icon, color, "X paid
/// Y" vs. "Paid by X") is branched once here instead of being duplicated
/// across every screen that lists expenses.
///
/// Callers own the interaction (tap-to-navigate, swipe-to-delete, or none) —
/// this widget is purely the card's contents.
class ExpenseTileContent extends StatelessWidget {
  const ExpenseTileContent({
    super.key,
    required this.expense,
    required this.currentUser,
    required this.subtitleDetail,
    this.trailing,
  });

  final Expense expense;
  final Member currentUser;

  /// The part of the subtitle after "· " — a date in a single-group history
  /// list, or the group name in a cross-group feed.
  final String subtitleDetail;

  /// Rendered below the amount, e.g. a date, when the caller's list needs a
  /// second trailing line. Omitted entirely when null.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final payerLabel = expense.paidBy.id == currentUser.id
        ? 'You'
        : expense.paidBy.name;

    final String titleText;
    final String subtitleText;
    final Color amountColor;
    final Widget leading;
    if (expense.isPayment) {
      final toMember = expense.shares.first.member;
      final toLabel = toMember.id == currentUser.id ? 'You' : toMember.name;
      titleText = '$payerLabel paid $toLabel';
      subtitleText = 'Settle up · $subtitleDetail';
      amountColor = theme.colorScheme.primary;
      leading = CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.primaryTint,
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedMoneyExchange02,
          size: 18,
          color: theme.colorScheme.primary,
        ),
      );
    } else {
      titleText = expense.concept;
      subtitleText = 'Paid by $payerLabel · $subtitleDetail';
      amountColor = theme.colorScheme.foreground;
      leading = Avatar(name: payerLabel);
    }

    return ShadCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          leading,
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titleText, style: theme.textTheme.large),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitleText, style: theme.textTheme.muted),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatAmount(expense.amount),
                style: theme.textTheme.h4.copyWith(color: amountColor),
              ),
              if (trailing != null) ...[
                const SizedBox(height: AppSpacing.xs),
                trailing!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}
