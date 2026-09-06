import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/providers/auth_provider.dart';
import 'package:split/repositories/auth_repository.dart';
import 'package:split/screens/auth/auth_screen.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.error});

  final Object? error;
  int signInCallCount = 0;
  int signUpCallCount = 0;
  String? lastEmail;
  String? lastPassword;

  @override
  Stream<User?> authStateChanges() => Stream.value(null);

  @override
  User? get currentUser => null;

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async => null;

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCallCount++;
    lastEmail = email;
    lastPassword = password;
    if (error != null) throw error!;
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    signUpCallCount++;
    lastEmail = email;
    lastPassword = password;
    if (error != null) throw error!;
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError();
  }

  @override
  Future<void> updateDisplayName(String name) {
    throw UnimplementedError();
  }
}

Future<void> _pumpAuthScreen(
  WidgetTester tester,
  AuthRepository authRepository, {
  AuthMode initialMode = AuthMode.login,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(authRepository)],
      child: ShadApp(
        home: Scaffold(body: AuthScreen(initialMode: initialMode)),
      ),
    ),
  );
}

final _submitButton = find.byKey(const Key('emailPasswordSubmitButton'));

void main() {
  testWidgets('opens on the Login tab and submits via signIn', (
    tester,
  ) async {
    final authRepository = _FakeAuthRepository();
    await _pumpAuthScreen(tester, authRepository);

    expect(
      find.descendant(of: _submitButton, matching: find.text('Login')),
      findsOneWidget,
    );

    await tester.enterText(find.byType(ShadInput).at(0), 'alex@example.com');
    await tester.enterText(find.byType(ShadInput).at(1), 'correct-password');
    await tester.tap(_submitButton);
    await tester.pump();
    await tester.pump();

    expect(authRepository.signInCallCount, 1);
    expect(authRepository.signUpCallCount, 0);
    expect(authRepository.lastEmail, 'alex@example.com');
    expect(authRepository.lastPassword, 'correct-password');
  });

  testWidgets('opens on the Sign up tab and submits via signUp', (
    tester,
  ) async {
    final authRepository = _FakeAuthRepository();
    await _pumpAuthScreen(tester, authRepository, initialMode: AuthMode.signUp);

    expect(
      find.descendant(of: _submitButton, matching: find.text('Sign up')),
      findsOneWidget,
    );

    await tester.enterText(find.byType(ShadInput).at(0), 'new@example.com');
    await tester.enterText(find.byType(ShadInput).at(1), 'a-new-password');
    await tester.tap(_submitButton);
    await tester.pump();
    await tester.pump();

    expect(authRepository.signUpCallCount, 1);
    expect(authRepository.signInCallCount, 0);
  });

  testWidgets('tapping the Sign up tab switches the submit button to Sign up', (
    tester,
  ) async {
    final authRepository = _FakeAuthRepository();
    await _pumpAuthScreen(tester, authRepository);

    // While on the Login tab, 'Sign up' appears exactly once (the inactive
    // tab's own label) — the submit button says 'Login' at this point, so
    // there's no collision to disambiguate here.
    await tester.tap(find.text('Sign up'));
    await tester.pump();

    expect(
      find.descendant(of: _submitButton, matching: find.text('Sign up')),
      findsOneWidget,
    );
  });

  testWidgets('shows a field error under password on wrong-password', (
    tester,
  ) async {
    final authRepository = _FakeAuthRepository(
      // ignore: invalid_use_of_protected_member
      error: FirebaseAuthException(code: 'wrong-password'),
    );
    await _pumpAuthScreen(tester, authRepository);

    await tester.enterText(find.byType(ShadInput).at(0), 'alex@example.com');
    await tester.enterText(find.byType(ShadInput).at(1), 'wrong-password');
    await tester.tap(_submitButton);
    await tester.pump();
    await tester.pump();

    expect(find.text('Incorrect password.'), findsOneWidget);
  });

  testWidgets('toggles password visibility', (tester) async {
    final authRepository = _FakeAuthRepository();
    await _pumpAuthScreen(tester, authRepository);

    final passwordInputFinder = find.byType(ShadInput).at(1);
    ShadInput passwordInput = tester.widget(passwordInputFinder);
    expect(passwordInput.obscureText, isTrue);

    await tester.tap(find.byIcon(LucideIcons.eyeOff));
    await tester.pump();

    passwordInput = tester.widget(passwordInputFinder);
    expect(passwordInput.obscureText, isFalse);
  });
}
