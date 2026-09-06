import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../theme/app_spacing.dart';

/// Email + password fields shared by [AuthScreen]'s login and sign-up
/// modes. Shape validation (non-empty, looks like an email) runs through
/// [ShadInputFormField]'s own synchronous validator; [emailError]/
/// [passwordError]/[generalError] carry a server-side error that arrived
/// asynchronously after a failed submit, so they're rendered separately
/// rather than through that same validator mechanism.
class EmailPasswordForm extends StatefulWidget {
  const EmailPasswordForm({
    super.key,
    required this.formKey,
    required this.isSubmitting,
    required this.onSubmit,
    required this.submitLabel,
    this.emailError,
    this.passwordError,
    this.generalError,
  });

  final GlobalKey<ShadFormState> formKey;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final String submitLabel;
  final String? emailError;
  final String? passwordError;
  final String? generalError;

  @override
  State<EmailPasswordForm> createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends State<EmailPasswordForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final errorStyle = theme.textTheme.small.copyWith(
      color: theme.colorScheme.destructive,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ShadForm(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShadInputFormField(
                id: 'email',
                label: const Text('Email'),
                placeholder: const Text('you@example.com'),
                keyboardType: TextInputType.emailAddress,
                description: widget.emailError != null
                    ? Text(widget.emailError!, style: errorStyle)
                    : null,
                validator: (v) {
                  if (v.trim().isEmpty) return 'Enter your email';
                  if (!v.contains('@')) return 'Enter a valid email address';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              ShadInputFormField(
                id: 'password',
                label: const Text('Password'),
                placeholder: const Text('••••••••'),
                obscureText: _obscurePassword,
                trailing: SizedBox.square(
                  dimension: 16,
                  child: OverflowBox(
                    maxWidth: 28,
                    maxHeight: 28,
                    child: ShadIconButton.ghost(
                      iconSize: 20,
                      padding: const EdgeInsets.all(2),
                      icon: HugeIcon(
                        icon: _obscurePassword
                            ? HugeIcons.strokeRoundedViewOff
                            : HugeIcons.strokeRoundedView,
                        color: theme.colorScheme.mutedForeground,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                ),
                description: widget.passwordError != null
                    ? Text(widget.passwordError!, style: errorStyle)
                    : null,
                validator: (v) {
                  if (v.isEmpty) return 'Enter your password';
                  return null;
                },
              ),
            ],
          ),
        ),
        if (widget.generalError != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(widget.generalError!, style: errorStyle),
        ],
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: ShadButton(
            key: const Key('emailPasswordSubmitButton'),
            onPressed: widget.isSubmitting ? null : widget.onSubmit,
            child: widget.isSubmitting
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
        ),
      ],
    );
  }
}
