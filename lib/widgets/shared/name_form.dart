import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../providers/auth_provider.dart';
import '../../providers/current_member_provider.dart';
import '../../providers/member_provider.dart';
import '../../theme/app_spacing.dart';
import '../../utils/network_exception.dart';

/// Form for setting the signed-in user's display name. Saving updates both
/// the Firebase user's display name and the backend `Member`.
///
/// Shared by the onboarding `SetNameScreen` and the profile edit flow, which
/// only differ in copy, initial value, and what happens after a save.
class NameForm extends ConsumerStatefulWidget {
  const NameForm({
    super.key,
    this.initialName,
    required this.submitLabel,
    this.onSaved,
  });

  final String? initialName;
  final String submitLabel;
  final VoidCallback? onSaved;

  @override
  ConsumerState<NameForm> createState() => _NameFormState();
}

class _NameFormState extends ConsumerState<NameForm> {
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
      widget.onSaved?.call();
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShadForm(
          key: _formKey,
          child: ShadInputFormField(
            id: 'name',
            label: const Text('Your name'),
            placeholder: const Text('Alex Rivera'),
            initialValue: widget.initialName,
            validator: (v) => v.trim().isEmpty ? 'Enter your name' : null,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        ShadButton(
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
              : Text(widget.submitLabel),
        ),
      ],
    );
  }
}
