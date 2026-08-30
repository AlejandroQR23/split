// test/utils/auth_error_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:split/utils/auth_error.dart';

void main() {
  group('mapFirebaseAuthErrorCode', () {
    test('maps wrong-password to the password field', () {
      final error = mapFirebaseAuthErrorCode('wrong-password');
      expect(error.password, 'Incorrect password.');
      expect(error.email, isNull);
      expect(error.general, isNull);
    });

    test('maps invalid-credential to the password field', () {
      final error = mapFirebaseAuthErrorCode('invalid-credential');
      expect(error.password, 'Incorrect password.');
    });

    test('maps user-not-found to the email field', () {
      final error = mapFirebaseAuthErrorCode('user-not-found');
      expect(error.email, 'No account found with this email.');
    });

    test('maps email-already-in-use to the email field', () {
      final error = mapFirebaseAuthErrorCode('email-already-in-use');
      expect(error.email, 'An account already exists with this email.');
    });

    test('maps weak-password to the password field', () {
      final error = mapFirebaseAuthErrorCode('weak-password');
      expect(error.password, 'Password must be at least 6 characters.');
    });

    test('maps invalid-email to the email field', () {
      final error = mapFirebaseAuthErrorCode('invalid-email');
      expect(error.email, 'Enter a valid email address.');
    });

    test('maps an unrecognized code to a general error', () {
      final error = mapFirebaseAuthErrorCode('network-request-failed');
      expect(error.general, 'Something went wrong. Please try again.');
      expect(error.email, isNull);
      expect(error.password, isNull);
    });
  });
}
