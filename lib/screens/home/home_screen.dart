import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:split/providers/current_member_provider.dart';
import 'package:split/widgets/balance/balance_stat.dart';
import 'package:split/widgets/groups/recent_groups_section.dart';
import 'package:split/widgets/history/recent_activity_section.dart';
import 'package:split/widgets/navigation/screen_header.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(requireCurrentMemberProvider);

    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.background),
      child: Column(
        children: [
          ScreenHeader(title: 'Hi, ${currentUser.name}', isMainScreen: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: AppSpacing.xxxl * 2,
              ),
              children: [
                BalanceSummaryCard(
                  onAddExpense: () => context.push('/add-expense'),
                ),
                const SizedBox(height: AppSpacing.xl),
                RecentActivitySection(currentUser: currentUser),
                const SizedBox(height: AppSpacing.xl),
                RecentGroupsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
