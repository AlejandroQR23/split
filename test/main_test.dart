import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:split/main.dart';
import 'package:split/models/member.dart';
import 'package:split/providers/auth_provider.dart';
import 'package:split/providers/http_provider.dart';
import 'package:split/providers/member_provider.dart';
import 'package:split/repositories/auth_repository.dart';
import 'package:split/repositories/member_repository.dart';

class _SignedOutAuthRepository implements AuthRepository {
  @override
  Stream<User?> authStateChanges() => Stream.value(null);

  @override
  User? get currentUser => null;

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async => null;

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

  @override
  Future<void> updateDisplayName(String name) {
    throw UnimplementedError();
  }
}

/// An [AuthRepository] whose sign-in state is driven manually by the test via
/// [emit], so the exact interleaving of auth-state changes and member fetches
/// can be controlled frame by frame.
class _ControllableAuthRepository implements AuthRepository {
  final _controller = StreamController<User?>.broadcast();

  @override
  User? currentUser;

  void emit(User? user) {
    currentUser = user;
    _controller.add(user);
  }

  @override
  Stream<User?> authStateChanges() => _controller.stream;

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async => null;

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

  @override
  Future<void> updateDisplayName(String name) {
    throw UnimplementedError();
  }
}

/// A [MemberRepository] whose `fetchMe()` calls stay pending until the test
/// completes them explicitly, so the "still fetching" window after sign-in
/// can be inspected.
class _ControllableMemberRepository implements MemberRepository {
  final completers = <Completer<Member>>[];

  @override
  Future<Member> fetchMe() {
    final completer = Completer<Member>();
    completers.add(completer);
    return completer.future;
  }

  @override
  Future<Member> addMember(String name) => throw UnimplementedError();

  @override
  Future<Member> updateName(String memberId, String name) =>
      throw UnimplementedError();
}

void main() {
  testWidgets(
    'signing out while HomeScreen is mounted, then back in, does not crash',
    (tester) async {
      final fakeAuth = _ControllableAuthRepository();
      final fakeMemberRepository = _ControllableMemberRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuth),
            memberRepositoryProvider.overrideWithValue(fakeMemberRepository),
            httpClientProvider.overrideWithValue(
              MockClient(
                (request) async => http.Response(
                  '{"groups": [], "expenses": [], "settlements": [], '
                  '"transfers": []}',
                  200,
                ),
              ),
            ),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pump();

      // Sign in and let the member fetch resolve, landing on HomeScreen —
      // which watches `currentMemberProvider` directly, and transitively via
      // the group/expense/settlement repository providers.
      fakeAuth.emit(MockUser(uid: 'user-1'));
      await tester.pump();
      fakeMemberRepository.completers.single.complete(
        const Member(id: 'mem_01h', name: 'Alex Rivera'),
      );
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Sign out while HomeScreen is still mounted — mirrors tapping
      // "sign out" on the profile screen. `currentMemberProvider` resolves
      // to `null` as part of Riverpod's provider-graph flush, which runs
      // *before* Flutter's widget tree gets a chance to rebuild/unmount
      // HomeScreen for this same state change. Every provider HomeScreen
      // watches is therefore still active at that point, so none of them may
      // throw an uncaught error into that flush — it would escape straight
      // out of `ProviderScope.build()` and blow up the root of the tree.
      fakeAuth.emit(null);
      await tester.pump();

      expect(tester.takeException(), isNull);

      // And sign back in — the originally reported symptom was a ~1s flash of
      // the Riverpod error screen on this step, caused by the exception the
      // sign-out above had already thrown.
      fakeAuth.emit(MockUser(uid: 'user-2'));
      await tester.pump();
      fakeMemberRepository.completers.last.complete(
        const Member(id: 'mem_02h', name: 'Sam Lee'),
      );
      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Hi, Sam Lee'), findsOneWidget);
    },
  );

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
