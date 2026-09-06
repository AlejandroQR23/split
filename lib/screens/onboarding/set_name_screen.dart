import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../providers/auth_provider.dart';
import '../../providers/current_member_provider.dart';
import '../../providers/member_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../utils/network_exception.dart';

/// Shown once, right after sign-up (or on any later launch where the
/// account's name is still the backend's placeholder — see
/// [Member.placeholderName]). Saving here updates both the Firebase user's
/// display name and the backend `Member`.
class SetNameScreen extends ConsumerStatefulWidget {
  const SetNameScreen({super.key});

  @override
  ConsumerState<SetNameScreen> createState() => _SetNameScreenState();
}

class _SetNameScreenState extends ConsumerState<SetNameScreen> {
  final _formKey = GlobalKey<ShadFormState>();
  bool _isSubmitting = false;

  Future<void> _handleSubmit() async {
    final formOk = _formKey.currentState?.saveAndValidate() ?? false;
    if (!formOk) return;

    final name = (_formKey.currentState!.value['name'] as String).trim();

    setState(() => _isSubmitting = true);
    try {
      final member = ref.read(currentMemberProvider).value;
      await ref.read(authRepositoryProvider).updateDisplayName(name);
      if (member != null) {
        await ref.read(memberRepositoryProvider).updateName(member.id, name);
      }
      ref.invalidate(currentMemberProvider);
    } catch (error) {
      if (!mounted) return;
      final message = error is NetworkException
          ? error.error.message
          : 'Something went wrong. Please try again.';
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('Could not save your name'),
          description: Text(message),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            ShadForm(
              key: _formKey,
              child: ShadInputFormField(
                id: 'name',
                label: const Text('Your name'),
                placeholder: const Text('Alex Rivera'),
                validator: (v) => v.trim().isEmpty ? 'Enter your name' : null,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ShadButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                child: _isSubmitting
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primaryForeground,
                        ),
                      )
                    : const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
