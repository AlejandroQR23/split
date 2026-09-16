import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/models/invite.dart';
import 'package:split/models/member.dart';
import 'package:split/models/transfer.dart';
import 'package:split/providers/invite_provider.dart';
import 'package:split/repositories/invite_repository.dart';
import 'package:split/widgets/settlement/transfer_card.dart';

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

const _alex = Member(id: 'mem_01h', name: 'Alex Rivera');
const _sam = Member(id: 'mem_02h', name: 'Sam Lee', isGhost: true);
const _observer = Member(id: 'mem_03h', name: 'Observer');
const _ghostFrom = Member(id: 'mem_04h', name: 'Jordan Kim', isGhost: true);

Future<void> _pumpTransferCard(
  WidgetTester tester, {
  required InviteRepository inviteRepository,
  bool canInvite = true,
  String fromId = 'mem_01h',
  String toId = 'mem_02h',
  Map<String, Member> memberById = const {'mem_01h': _alex, 'mem_02h': _sam},
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [inviteRepositoryProvider.overrideWithValue(inviteRepository)],
      child: ShadApp(
        home: Scaffold(
          body: TransferCard(
            transfer: Transfer(from: fromId, to: toId, amount: 20),
            currentUser: _observer,
            memberById: memberById,
            groupId: 'grp_01h',
            canInvite: canInvite,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows an invite action for a ghost counterparty', (tester) async {
    await _pumpTransferCard(
      tester,
      inviteRepository: _FakeInviteRepository(),
    );

    expect(find.text('Invite Sam Lee'), findsOneWidget);
    expect(find.textContaining('Invite Alex Rivera'), findsNothing);
  });

  testWidgets('tapping the invite action generates an invite for that member', (
    tester,
  ) async {
    final fakeInviteRepository = _FakeInviteRepository();
    await _pumpTransferCard(tester, inviteRepository: fakeInviteRepository);

    await tester.tap(find.text('Invite Sam Lee'));
    await tester.pump();

    expect(fakeInviteRepository.lastGeneratedMemberId, 'mem_02h');
  });

  testWidgets('shows an invite action for a ghost payer (from)', (
    tester,
  ) async {
    await _pumpTransferCard(
      tester,
      inviteRepository: _FakeInviteRepository(),
      fromId: 'mem_04h',
      toId: 'mem_01h',
      memberById: const {'mem_04h': _ghostFrom, 'mem_01h': _alex},
    );

    expect(find.text('Invite Jordan Kim'), findsOneWidget);
    expect(find.textContaining('Invite Alex Rivera'), findsNothing);
  });

  testWidgets(
    'tapping the invite action for a ghost payer (from) generates an '
    'invite for that member',
    (tester) async {
      final fakeInviteRepository = _FakeInviteRepository();
      await _pumpTransferCard(
        tester,
        inviteRepository: fakeInviteRepository,
        fromId: 'mem_04h',
        toId: 'mem_01h',
        memberById: const {'mem_04h': _ghostFrom, 'mem_01h': _alex},
      );

      await tester.tap(find.text('Invite Jordan Kim'));
      await tester.pump();

      expect(fakeInviteRepository.lastGeneratedMemberId, 'mem_04h');
    },
  );

  testWidgets(
    'canInvite: false suppresses the invite row even when a party is a '
    'ghost',
    (tester) async {
      await _pumpTransferCard(
        tester,
        inviteRepository: _FakeInviteRepository(),
        canInvite: false,
      );

      expect(find.textContaining('Invite'), findsNothing);
    },
  );
}
