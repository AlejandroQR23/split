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
      return const AuthFieldError(password: 'Contraseña incorrecta.');
    case 'user-not-found':
      return const AuthFieldError(
        email: 'No encontramos ninguna cuenta con ese correo.',
      );
    case 'email-already-in-use':
      return const AuthFieldError(
        email: 'Ya existe una cuenta con ese correo.',
      );
    case 'weak-password':
      return const AuthFieldError(
        password: 'La contraseña debe tener al menos 6 caracteres.',
      );
    case 'invalid-email':
      return const AuthFieldError(email: 'Ingresa un correo válido.');
    default:
      return const AuthFieldError(
        general: 'Algo salió mal. Intenta de nuevo.',
      );
  }
}
