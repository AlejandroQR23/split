import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:split/main.dart';
import 'package:split/providers/auth_provider.dart';
import 'package:split/repositories/auth_repository.dart';

class _SignedOutAuthRepository implements AuthRepository {
  @override
  Stream<User?> authStateChanges() => Stream.value(null);

  @override
  User? get currentUser => null;

  @override
  Future<void> signIn({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<void> signUp({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('redirects to sign-in when signed out', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_SignedOutAuthRepository()),
        ],
        child: const MyApp(),
      ),
    );

    // First pump resolves authStateProvider past its initial loading state;
    // second lets go_router's redirect settle onto /sign-in.
    await tester.pump();
    await tester.pump();

    expect(find.text('Welcome back!'), findsOneWidget);
  });
}
