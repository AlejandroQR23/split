import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../utils/auth_error.dart';
import '../../widgets/auth/email_password_form.dart';

/// Which of the two forms [AuthScreen] is showing. Both the `/sign-in` and
/// `/sign-up` routes render this same screen, differing only in which mode
/// it opens on — switching between them afterwards is an in-place tab
/// change, not a navigation.
enum AuthMode { login, signUp }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, required this.initialMode});

  final AuthMode initialMode;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late AuthMode _mode = widget.initialMode;
  final _formKey = GlobalKey<ShadFormState>();
  bool _isSubmitting = false;
  AuthFieldError _fieldError = const AuthFieldError();

  void _switchMode(AuthMode mode) {
    if (mode == _mode) return;
    setState(() {
      _mode = mode;
      _fieldError = const AuthFieldError();
    });
  }

  Future<void> _handleSubmit() async {
    final formOk = _formKey.currentState?.saveAndValidate() ?? false;
    if (!formOk) return;

    final email = _formKey.currentState!.value['email'] as String;
    final password = _formKey.currentState!.value['password'] as String;

    setState(() {
      _isSubmitting = true;
      _fieldError = const AuthFieldError();
    });

    try {
      final repository = ref.read(authRepositoryProvider);
      if (_mode == AuthMode.login) {
        await repository.signIn(email: email.trim(), password: password);
      } else {
        await repository.signUp(email: email.trim(), password: password);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _fieldError = mapFirebaseAuthErrorCode(e.code);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _fieldError = const AuthFieldError(
          general: 'Something went wrong. Please try again.',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

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
            Text(
              'Split',
              style: theme.textTheme.large.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('Welcome back!', style: AppTypography.screenTitle),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Split expenses with friends, the easy way.',
              style: theme.textTheme.muted,
            ),
            const SizedBox(height: AppSpacing.xl),
            ShadTabs<AuthMode>(
              value: _mode,
              onChanged: _switchMode,
              tabs: const [
                ShadTab(value: AuthMode.login, child: Text('Login')),
                ShadTab(value: AuthMode.signUp, child: Text('Sign up')),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            EmailPasswordForm(
              key: ValueKey(_mode),
              formKey: _formKey,
              isSubmitting: _isSubmitting,
              onSubmit: _handleSubmit,
              submitLabel: _mode == AuthMode.login ? 'Login' : 'Sign up',
              emailError: _fieldError.email,
              passwordError: _fieldError.password,
              generalError: _fieldError.general,
            ),
          ],
        ),
      ),
    );
  }
}
