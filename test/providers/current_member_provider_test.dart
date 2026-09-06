import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:split/models/member.dart';
import 'package:split/providers/auth_provider.dart';
import 'package:split/providers/current_member_provider.dart';
import 'package:split/providers/member_provider.dart';
import 'package:split/repositories/auth_repository.dart';
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

}
