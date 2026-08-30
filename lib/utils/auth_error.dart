/// Which of the sign-in/sign-up form's fields a Firebase Auth error should
/// be shown under. Deliberately separate from `FirebaseAuthException` so
/// this mapping is unit-testable without constructing (or mocking) a real
/// Firebase exception.
class AuthFieldError {
  const AuthFieldError({this.email, this.password, this.general});

  final String? email;
  final String? password;
  final String? general;
}

AuthFieldError mapFirebaseAuthErrorCode(String code) {
  switch (code) {
    case 'wrong-password':
    case 'invalid-credential':
      return const AuthFieldError(password: 'Incorrect password.');
    case 'user-not-found':
      return const AuthFieldError(email: 'No account found with this email.');
    case 'email-already-in-use':
      return const AuthFieldError(
        email: 'An account already exists with this email.',
      );
    case 'weak-password':
      return const AuthFieldError(
        password: 'Password must be at least 6 characters.',
      );
    case 'invalid-email':
      return const AuthFieldError(email: 'Enter a valid email address.');
    default:
      return const AuthFieldError(
        general: 'Something went wrong. Please try again.',
      );
  }
}
