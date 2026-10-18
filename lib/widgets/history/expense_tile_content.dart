import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/expense.dart';
import '../../models/member.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/formatting.dart';
import '../../utils/member_label.dart';
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
    final payerLabel = subjectLabel(expense.paidBy, currentUser: currentUser);

    final String titleText;
    final String subtitleText;
    final Color amountColor;
    final Widget leading;
    if (expense.isPayment) {
      final toMember = expense.shares.first.member;
      final toIsMe = toMember.id == currentUser.id;
      final toLabel = objectLabel(toMember, currentUser: currentUser);
      final paidVerb = expense.paidBy.id == currentUser.id
          ? 'le pagaste a'
          : 'le pagó a';
      titleText = toIsMe
          ? '$payerLabel te pagó'
          : '$payerLabel $paidVerb $toLabel';
      subtitleText = 'Pago a manu · $subtitleDetail';
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
      final paidByLabel = objectLabel(expense.paidBy, currentUser: currentUser);
      subtitleText = 'Pagado por $paidByLabel · $subtitleDetail';
      amountColor = theme.colorScheme.foreground;
      leading = Avatar(name: payerLabel);
    }

    Widget titleWidget = Text(titleText, style: theme.textTheme.large);
    if (!expense.isPayment && expense.isRecurring) {
      titleWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: titleWidget),
          const SizedBox(width: AppSpacing.xs),
          HugeIcon(
            icon: HugeIcons.strokeRoundedRepeat,
            size: 14,
            color: theme.colorScheme.mutedForeground,
          ),
        ],
      );
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
                titleWidget,
                const SizedBox(height: AppSpacing.xs),
                Text(subtitleText, style: theme.textTheme.muted),
                if (expense.label != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  ShadBadge.raw(
                    variant: ShadBadgeVariant.secondary,
                    backgroundColor: expense.label!.color.withValues(
                      alpha: 0.15,
                    ),
                    foregroundColor: expense.label!.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: Text(
                      [
                        if (expense.label!.icon != null) expense.label!.icon!,
                        expense.label!.name,
                      ].join(' '),
                    ),
                  ),
                ],
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
