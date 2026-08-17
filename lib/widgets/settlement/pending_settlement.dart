import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/widgets/animations/reveal_animation_state.dart';
import 'package:split/widgets/animations/staggered_reveal_items.dart';

import '../../models/member.dart';
import '../../models/transfer.dart';
import '../../theme/app_spacing.dart';
import 'transfer_card.dart';

class PendingSettlementsSection extends StatefulWidget {
  const PendingSettlementsSection({
    super.key,
    required this.transfers,
    required this.currentUser,
    required this.members,
  });

  final List<Transfer> transfers;
  final Member currentUser;
  final List<Member> members;

  @override
  State<PendingSettlementsSection> createState() =>
      _PendingSettlementsSectionState();
}

class _PendingSettlementsSectionState
    extends RevealAnimationState<PendingSettlementsSection, Transfer> {
  @override
  List<Transfer> getItems(PendingSettlementsSection widget) => widget.transfers;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final memberById = {for (final member in widget.members) member.id: member};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pending settlements', style: theme.textTheme.h4),
            ShadBadge.secondary(
              child: Text(
                widget.transfers.isEmpty
                    ? 'All settled'
                    : '${widget.transfers.length} pending',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (widget.transfers.isEmpty)
          const _EmptySettlementsState()
        else
          StaggeredRevealItems(
            animation: animationController,
            spacing: AppSpacing.md,
            children: [
              for (final transfer in widget.transfers)
                TransferCard(
                  transfer: transfer,
                  currentUser: widget.currentUser,
                  memberById: memberById,
                ),
            ],
          ),
      ],
    );
  }
}

class _EmptySettlementsState extends StatelessWidget {
  const _EmptySettlementsState();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadCard(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      rowMainAxisAlignment: MainAxisAlignment.center,
      columnCrossAxisAlignment: CrossAxisAlignment.center,
      child: Column(
        children: [
          Icon(
            LucideIcons.badgeCheck,
            color: theme.colorScheme.primary,
            size: 32,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text("You're all settled up", style: theme.textTheme.large),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'No pending settlements in this group.',
            style: theme.textTheme.muted,
          ),
        ],
      ),
    );
  }
}
