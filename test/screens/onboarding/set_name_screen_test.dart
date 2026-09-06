import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/models/member.dart';
import 'package:split/providers/auth_provider.dart';
import 'package:split/providers/current_member_provider.dart';
import 'package:split/providers/member_provider.dart';
import 'package:split/repositories/auth_repository.dart';
import 'package:split/repositories/member_repository.dart';
import 'package:split/screens/onboarding/set_name_screen.dart';
import 'package:split/utils/network_exception.dart';

class _FakeAuthRepository implements AuthRepository {
  int updateDisplayNameCallCount = 0;
  String? lastDisplayName;

  @override
  Stream<User?> authStateChanges() => Stream.value(null);

  @override
  User? get currentUser => null;

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async => null;

  @override
  Future<void> signIn({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<void> signUp({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<void> signOut() => throw UnimplementedError();

  @override
  Future<void> updateDisplayName(String name) async {
    updateDisplayNameCallCount++;
    lastDisplayName = name;
  }
}

class _FakeMemberRepository implements MemberRepository {
  _FakeMemberRepository({this.updateNameError});

  final Object? updateNameError;
  int updateNameCallCount = 0;
  String? lastMemberId;
  String? lastName;

  @override
  Future<Member> addMember(String name) => throw UnimplementedError();

  @override
  Future<Member> fetchMe() => throw UnimplementedError();

  @override
  Future<Member> updateName(String memberId, String name) async {
    updateNameCallCount++;
    lastMemberId = memberId;
    lastName = name;
    if (updateNameError != null) throw updateNameError!;
    return Member(id: memberId, name: name);
  }
}

Future<void> _pumpSetNameScreen(
  WidgetTester tester, {
  required AuthRepository authRepository,
  required MemberRepository memberRepository,
  Member? currentMember = const Member(id: 'mem_01h', name: 'New member'),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        memberRepositoryProvider.overrideWithValue(memberRepository),
        currentMemberProvider.overrideWith((ref) async => currentMember),
      ],
      child: const ShadApp(home: Scaffold(body: SetNameScreen())),
    ),
  );
  // Let currentMemberProvider's overridden future resolve.
  await tester.pump();
}

void main() {
  testWidgets('shows a validation error and makes no calls when empty', (
    tester,
  ) async {
    final authRepository = _FakeAuthRepository();
    final memberRepository = _FakeMemberRepository();
    await _pumpSetNameScreen(
      tester,
      authRepository: authRepository,
      memberRepository: memberRepository,
    );

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Enter your name'), findsOneWidget);
    expect(authRepository.updateDisplayNameCallCount, 0);
    expect(memberRepository.updateNameCallCount, 0);
  });

  testWidgets(
    'updates the Firebase display name and the backend Member on submit',
    (tester) async {
      final authRepository = _FakeAuthRepository();
      final memberRepository = _FakeMemberRepository();
      await _pumpSetNameScreen(
        tester,
        authRepository: authRepository,
        memberRepository: memberRepository,
      );

      await tester.enterText(find.byType(ShadInput), 'Alex Rivera');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(authRepository.updateDisplayNameCallCount, 1);
      expect(authRepository.lastDisplayName, 'Alex Rivera');
      expect(memberRepository.updateNameCallCount, 1);
      expect(memberRepository.lastMemberId, 'mem_01h');
      expect(memberRepository.lastName, 'Alex Rivera');
    },
  );

  testWidgets('shows a toast when saving the name fails', (tester) async {
    final authRepository = _FakeAuthRepository();
    final memberRepository = _FakeMemberRepository(
      updateNameError: NetworkException(
        APIError(message: 'Could not reach the server', code: 'network'),
        500,
      ),
    );
    await _pumpSetNameScreen(
      tester,
      authRepository: authRepository,
      memberRepository: memberRepository,
    );

    await tester.enterText(find.byType(ShadInput), 'Alex Rivera');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Could not reach the server'), findsOneWidget);
  });
}
