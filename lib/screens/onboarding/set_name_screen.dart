import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../providers/current_member_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/shared/name_form.dart';

/// Shown once, right after sign-up (or on any later launch where the
/// account's name is still the backend's placeholder — see
/// [Member.placeholderName]). Saving here updates both the Firebase user's
/// display name and the backend `Member`.
class SetNameScreen extends ConsumerWidget {
  const SetNameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);

    ref.watch(currentMemberProvider);

    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.background),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xxl,
            AppSpacing.xl,
            AppSpacing.xxxl,
          ),
          children: [
            Text('What should we call you?', style: AppTypography.screenTitle),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'This is the name your group-mates will see.',
              style: theme.textTheme.muted,
            ),
            const SizedBox(height: AppSpacing.xl),
            const NameForm(submitLabel: 'Continue'),
          ],
        ),
      ),
    );
  }
}
