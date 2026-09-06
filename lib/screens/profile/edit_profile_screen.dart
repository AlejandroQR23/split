import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/current_member_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/navigation/screen_header.dart';
import '../../widgets/shared/name_form.dart';

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(currentMemberProvider).value;
    if (member == null) return const SizedBox.shrink();

    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.background),
      child: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Edit Profile'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                children: [
                  NameForm(
                    initialName: member.name,
                    submitLabel: 'Save Changes',
                    onSaved: () => context.pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
