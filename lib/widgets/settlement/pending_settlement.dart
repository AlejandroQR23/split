import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../theme/app_spacing.dart';
import 'settlement_card.dart';

class PendingSettlementsSection extends StatelessWidget {
  const PendingSettlementsSection({super.key, required this.settlements});

  final List<Settlement> settlements;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pending settlements', style: theme.textTheme.h4),
            ShadBadge.secondary(
              child: Text(
                settlements.isEmpty
                    ? 'All settled'
                    : '${settlements.length} pending',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (settlements.isEmpty)
          const _EmptySettlementsState()
        else
          for (final settlement in settlements) ...[
            SettlementCard(settlement: settlement),
            const SizedBox(height: AppSpacing.md),
          ],
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
