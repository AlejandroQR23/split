// test/utils/auth_error_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:split/utils/auth_error.dart';

void main() {
  group('mapFirebaseAuthErrorCode', () {
    test('maps wrong-password to the password field', () {
      final error = mapFirebaseAuthErrorCode('wrong-password');
      expect(error.password, 'Contraseña incorrecta.');
      expect(error.email, isNull);
      expect(error.general, isNull);
    });

    test('maps invalid-credential to the password field', () {
      final error = mapFirebaseAuthErrorCode('invalid-credential');
      expect(error.password, 'Contraseña incorrecta.');
    });

    test('maps user-not-found to the email field', () {
      final error = mapFirebaseAuthErrorCode('user-not-found');
      expect(error.email, 'No encontramos ninguna cuenta con ese correo.');
    });

    test('maps email-already-in-use to the email field', () {
      final error = mapFirebaseAuthErrorCode('email-already-in-use');
      expect(error.email, 'Ya existe una cuenta con ese correo.');
    });

    test('maps weak-password to the password field', () {
      final error = mapFirebaseAuthErrorCode('weak-password');
      expect(error.password, 'La contraseña debe tener al menos 6 caracteres.');
    });

    test('maps invalid-email to the email field', () {
      final error = mapFirebaseAuthErrorCode('invalid-email');
      expect(error.email, 'Ingresa un correo válido.');
    });

    test('maps an unrecognized code to a general error', () {
      final error = mapFirebaseAuthErrorCode('network-request-failed');
      expect(error.general, 'Algo salió mal. Intenta de nuevo.');
      expect(error.email, isNull);
      expect(error.password, isNull);
    });
  });
}
