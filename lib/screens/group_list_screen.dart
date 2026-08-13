import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/providers/groups_provider.dart';

import '../models/group.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Shows every group the (hypothetical) current user belongs to, each with
/// its member names visible.
class GroupListScreen extends ConsumerWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsResponse = ref.watch(groupsProvider);

    final theme = ShadTheme.of(context);

    return switch (groupsResponse) {
      AsyncData<List<Group>> data => DecoratedBox(
        decoration: const BoxDecoration(color: AppColors.background),
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.xl),
            itemCount: data.value.length + 1,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.lg),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Text('Your groups', style: AppTypography.screenTitle);
              }
              return _GroupCard(group: data.value[index - 1]);
            },
          ),
        ),
      ),
      AsyncLoading() => Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      ),
      AsyncError(error: final error) => Center(
        child: Text(
          'Error: $error',
          style: theme.textTheme.p.copyWith(
            color: theme.colorScheme.destructive,
          ),
        ),
      ),
    };
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final memberCount = group.members.length;

    return ShadCard(
      title: Text(group.name, style: theme.textTheme.h4),
      description: Text(memberCount == 1 ? '1 member' : '$memberCount members'),
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final member in group.members)
              ShadBadge.secondary(child: Text(member.name)),
          ],
        ),
      ),
    );
  }
}
