import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/group.dart';
import '../../providers/invite_provider.dart';
import '../../theme/app_spacing.dart';
import '../../utils/network_exception.dart';
import '../settlement/pending_settlement.dart';
import 'guest_viewer_sentinel.dart';
import 'invite_balance_card.dart';
import 'invite_expenses_list.dart';

class InviteGroupSection extends ConsumerWidget {
  const InviteGroupSection({
    super.key,
    required this.token,
    required this.group,
    required this.invitedMemberName,
  });

  final String token;
  final Group group;
  final String invitedMemberName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final key = (token: token, groupId: group.id);
    final transfersAsync = ref.watch(inviteGroupTransfersProvider(key));
    final expensesAsync = ref.watch(inviteGroupExpensesProvider(key));
    final invitedMember = group.members.firstWhere(
      (member) => member.name == invitedMemberName,
      orElse: () => guestViewerSentinel,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(group.name, style: theme.textTheme.h4),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            for (final member in group.members)
              ShadBadge.secondary(child: Text(member.name)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        transfersAsync.when(
          skipError: true,
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) => Text(
            error is NetworkException && error.error.code == 'unauthenticated'
                ? 'This invite has expired — ask for a new link.'
                : "Couldn't load this group's activity.",
            style: theme.textTheme.muted,
          ),
          data: (transfers) {
            final memberTransfers = transfers
                .where(
                  (transfer) =>
                      transfer.from == invitedMember.id ||
                      transfer.to == invitedMember.id,
                )
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InviteBalanceCard(
                  memberName: invitedMemberName,
                  memberId: invitedMember.id,
                  transfers: memberTransfers,
                ),
                const SizedBox(height: AppSpacing.lg),
                PendingSettlementsSection(
                  transfers: memberTransfers,
                  currentUser: guestViewerSentinel,
                  members: group.members,
                  groupId: group.id,
                  canInvite: false,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        expensesAsync.when(
          skipError: true,
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) => Text(
            error is NetworkException && error.error.code == 'unauthenticated'
                ? 'This invite has expired — ask for a new link.'
                : "Couldn't load this group's activity.",
            style: theme.textTheme.muted,
          ),
          data: (expenses) => InviteExpensesList(expenses: expenses),
        ),
      ],
    );
  }
}
