// test/widgets/groups/group_members_section_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/models/invite.dart';
import 'package:split/models/member.dart';
import 'package:split/providers/invite_provider.dart';
import 'package:split/repositories/invite_repository.dart';
import 'package:split/widgets/groups/group_members_section.dart';

class _FakeInviteRepository implements InviteRepository {
  String? lastGeneratedMemberId;

  @override
  Future<InvitePreview> fetchPreview(String token) =>
      throw UnimplementedError();

  @override
  Future<Member> claimInvite(String token) => throw UnimplementedError();

  @override
  Future<GeneratedInvite> generateInvite(String memberId) async {
    lastGeneratedMemberId = memberId;
    return GeneratedInvite(
      inviteToken: 'inv_xyz789',
      expiresAt: DateTime.now(),
    );
  }
}

void main() {
  const realMember = Member(id: 'mem_01h', name: 'Alex Rivera');
  const ghostMember = Member(id: 'mem_02h', name: 'Sam Lee', isGhost: true);

  testWidgets('member list is collapsed behind a stacked avatar by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: ShadApp(
          home: Scaffold(
            body: GroupMembersSection(members: [realMember, ghostMember]),
          ),
        ),
      ),
    );

    expect(find.text('Members'), findsOneWidget);
    expect(find.text('Alex Rivera'), findsNothing);
    expect(find.text('Sam Lee'), findsNothing);
    expect(find.text('Ghost'), findsNothing);
  });

  testWidgets('tapping the header expands the list and shows a Ghost badge '
      'only for ghost members', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: ShadApp(
          home: Scaffold(
            body: GroupMembersSection(members: [realMember, ghostMember]),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Members'));
    await tester.pumpAndSettle();

    expect(find.text('Ghost'), findsOneWidget);
    expect(find.text('Alex Rivera'), findsOneWidget);
    expect(find.text('Sam Lee'), findsOneWidget);
  });

  testWidgets('tapping Invite on a ghost generates an invite for that member', (
    tester,
  ) async {
    final fakeInviteRepository = _FakeInviteRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inviteRepositoryProvider.overrideWithValue(fakeInviteRepository),
        ],
        child: ShadApp(
          home: Scaffold(
            body: GroupMembersSection(members: [realMember, ghostMember]),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Members'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ShadIconButton));
    await tester.pump();

    expect(fakeInviteRepository.lastGeneratedMemberId, 'mem_02h');
  });
}
