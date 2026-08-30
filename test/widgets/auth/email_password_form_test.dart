import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/widgets/auth/email_password_form.dart';

void main() {
  Widget buildForm({
    required GlobalKey<ShadFormState> formKey,
    String? emailError,
    String? passwordError,
    String? generalError,
  }) {
    return ShadApp(
      home: Scaffold(
        body: EmailPasswordForm(
          formKey: formKey,
          isSubmitting: false,
          onSubmit: () => formKey.currentState!.saveAndValidate(),
          submitLabel: 'Sign in',
          emailError: emailError,
          passwordError: passwordError,
          generalError: generalError,
        ),
      ),
    );
  }

  testWidgets('shows validation errors when submitted empty', (tester) async {
    final formKey = GlobalKey<ShadFormState>();
    await tester.pumpWidget(buildForm(formKey: formKey));

    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });

  testWidgets('renders a passed-in password error', (tester) async {
    final formKey = GlobalKey<ShadFormState>();
    await tester.pumpWidget(
      buildForm(formKey: formKey, passwordError: 'Incorrect password.'),
    );
    await tester.pump();

    expect(find.text('Incorrect password.'), findsOneWidget);
  });

  testWidgets('renders a passed-in general error', (tester) async {
    final formKey = GlobalKey<ShadFormState>();
    await tester.pumpWidget(
      buildForm(formKey: formKey, generalError: 'Something went wrong.'),
    );
    await tester.pump();

    expect(find.text('Something went wrong.'), findsOneWidget);
  });
}
