import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:split/models/invite.dart';
import 'package:split/models/member.dart';
import 'package:split/providers/auth_provider.dart';
import 'package:split/providers/current_member_provider.dart';
import 'package:split/providers/invite_provider.dart';
import 'package:split/providers/member_provider.dart';
import 'package:split/repositories/auth_repository.dart';
import 'package:split/repositories/invite_repository.dart';
import 'package:split/repositories/member_repository.dart';

class _FakeMemberRepository implements MemberRepository {
  int fetchMeCallCount = 0;

  @override
  Future<Member> addMember(String name) => throw UnimplementedError();

  @override
  Future<Member> fetchMe() async {
    fetchMeCallCount++;
    return const Member(id: 'mem_01h', name: 'Alex Rivera');
  }

  @override
  Future<Member> updateName(String memberId, String name) =>
      throw UnimplementedError();
}

class _FakeInviteRepository implements InviteRepository {
  int claimInviteCallCount = 0;
  String? lastClaimedToken;

  @override
  Future<InvitePreview> fetchPreview(String token) =>
      throw UnimplementedError();

  @override
  Future<Member> claimInvite(String token) async {
    claimInviteCallCount++;
    lastClaimedToken = token;
    return const Member(id: 'mem_merged', name: 'Sam Lee');
  }

  @override
  Future<GeneratedInvite> generateInvite(String memberId) =>
      throw UnimplementedError();
}

class _FailingInviteRepository implements InviteRepository {
  int claimInviteCallCount = 0;

  @override
  Future<InvitePreview> fetchPreview(String token) =>
      throw UnimplementedError();

  @override
  Future<Member> claimInvite(String token) async {
    claimInviteCallCount++;
    throw Exception('claim failed');
  }

  @override
  Future<GeneratedInvite> generateInvite(String memberId) =>
      throw UnimplementedError();
}

void main() {
  test('resolves to null without calling fetchMe when signed out', () async {
    final fakeRepository = _FakeMemberRepository();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          FirebaseAuthRepository(MockFirebaseAuth(signedIn: false)),
        ),
        memberRepositoryProvider.overrideWithValue(fakeRepository),
      ],
    );
    addTearDown(container.dispose);
    container.listen(currentMemberProvider, (_, _) {});

    final member = await container.read(currentMemberProvider.future);

    expect(member, isNull);
    expect(fakeRepository.fetchMeCallCount, 0);
  });

  test('fetches and returns the Member when signed in', () async {
    final fakeRepository = _FakeMemberRepository();
    final mockAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1'),
    );
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          FirebaseAuthRepository(mockAuth),
        ),
        memberRepositoryProvider.overrideWithValue(fakeRepository),
      ],
    );
    addTearDown(container.dispose);
    container.listen(currentMemberProvider, (_, _) {});

    final member = await container.read(currentMemberProvider.future);

    expect(member?.id, 'mem_01h');
    expect(fakeRepository.fetchMeCallCount, 1);
  });

  test(
    'claims the pending invite instead of fetching Me when a token is pending',
    () async {
      final fakeMemberRepository = _FakeMemberRepository();
      final fakeInviteRepository = _FakeInviteRepository();
      final mockAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'u1'),
      );
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            FirebaseAuthRepository(mockAuth),
          ),
          memberRepositoryProvider.overrideWithValue(fakeMemberRepository),
          inviteRepositoryProvider.overrideWithValue(fakeInviteRepository),
          pendingInviteTokenProvider.overrideWith((ref) => 'inv_abc123'),
        ],
      );
      addTearDown(container.dispose);
      container.listen(currentMemberProvider, (_, _) {});

      final member = await container.read(currentMemberProvider.future);

      expect(member?.id, 'mem_merged');
      expect(fakeInviteRepository.claimInviteCallCount, 1);
      expect(fakeInviteRepository.lastClaimedToken, 'inv_abc123');
      expect(fakeMemberRepository.fetchMeCallCount, 0);
    },
  );

  test('clears the pending token after claiming', () async {
    final fakeInviteRepository = _FakeInviteRepository();
    final mockAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1'),
    );
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          FirebaseAuthRepository(mockAuth),
        ),
        memberRepositoryProvider.overrideWithValue(_FakeMemberRepository()),
        inviteRepositoryProvider.overrideWithValue(fakeInviteRepository),
        pendingInviteTokenProvider.overrideWith((ref) => 'inv_abc123'),
      ],
    );
    addTearDown(container.dispose);
    container.listen(currentMemberProvider, (_, _) {});

    await container.read(currentMemberProvider.future);

    expect(container.read(pendingInviteTokenProvider), isNull);
  });

  test(
    'clears the pending token even when claiming fails, so a retry falls '
    'through to fetchMe instead of looping the same claim',
    () async {
      final fakeMemberRepository = _FakeMemberRepository();
      final failingInviteRepository = _FailingInviteRepository();
      final mockAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'u1'),
      );
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            FirebaseAuthRepository(mockAuth),
          ),
          memberRepositoryProvider.overrideWithValue(fakeMemberRepository),
          inviteRepositoryProvider.overrideWithValue(failingInviteRepository),
          pendingInviteTokenProvider.overrideWith((ref) => 'inv_abc123'),
        ],
      );
      addTearDown(container.dispose);

      AsyncValue<Member?>? latest;
      container.listen(currentMemberProvider, (_, next) {
        latest = next;
      }, fireImmediately: true);

      // Let the failing `claimInvite` call's async gap resolve, but don't
      // wait long enough for Riverpod's default retry policy (200ms+
      // backoff) to fire a second build. Immediately after a failure,
      // Riverpod reports `AsyncLoading(retrying: true)` with the error
      // attached rather than a settled `AsyncError` — `hasError` is true
      // in both cases, which is exactly the check the rest of this
      // codebase already uses to work around this (see
      // `invite_screen.dart`'s history) — so that's what this asserts,
      // rather than the exact `AsyncValue` subtype.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(latest!.hasError, isTrue);
      expect(latest!.error, isA<Exception>());
      expect(failingInviteRepository.claimInviteCallCount, 1);
      expect(container.read(pendingInviteTokenProvider), isNull);
      expect(fakeMemberRepository.fetchMeCallCount, 0);
    },
  );
}
