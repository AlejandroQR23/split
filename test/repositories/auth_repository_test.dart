import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:split/repositories/auth_repository.dart';

void main() {
  group('updateDisplayName', () {
    test('sets the display name on the signed-in Firebase user', () async {
      final mockAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'u1'),
      );
      final repository = FirebaseAuthRepository(mockAuth);

      await repository.updateDisplayName('Alex Rivera');

      expect(mockAuth.currentUser?.displayName, 'Alex Rivera');
    });

    test('does nothing when signed out', () async {
      final mockAuth = MockFirebaseAuth(signedIn: false);
      final repository = FirebaseAuthRepository(mockAuth);

      await repository.updateDisplayName('Alex Rivera');

      expect(mockAuth.currentUser, isNull);
    });
  });
}
