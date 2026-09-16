import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:split/models/group.dart';
import 'package:split/models/invite.dart';
import 'package:split/models/member.dart';
import 'package:split/models/transfer.dart';
import 'package:split/providers/invite_provider.dart';
import 'package:split/screens/invites/invite_screen.dart';

const _token = 'inv_abc123';

Future<void> _pumpInviteScreen(
  WidgetTester tester, {
  required Future<InvitePreview> Function() fetchPreview,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        invitePreviewProvider(_token).overrideWith((ref) => fetchPreview()),
      ],
      child: const ShadApp(
        home: Scaffold(body: InviteScreen(token: _token)),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('shows the expired message when the preview says expired', (
    tester,
  ) async {
    await _pumpInviteScreen(
      tester,
      fetchPreview: () async => const InvitePreview(
        memberName: 'Sam Lee',
        expired: true,
        claimed: false,
      ),
    );

    expect(
      find.text('This invite has expired — ask for a new link.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'shows the already-used message when the preview says claimed',
    (tester) async {
      await _pumpInviteScreen(
        tester,
        fetchPreview: () async => const InvitePreview(
          memberName: 'Sam Lee',
          expired: false,
          claimed: true,
        ),
      );

      expect(find.text('This invite has already been used.'), findsOneWidget);
    },
  );

  testWidgets('shows a generic invalid message when the preview fetch fails', (
    tester,
  ) async {
    await _pumpInviteScreen(
      tester,
      fetchPreview: () => Future<InvitePreview>.error(Exception('not found')),
    );

    expect(find.text("This invite link isn't valid."), findsOneWidget);
  });

  testWidgets(
    'suppresses the Settle up tap target for a transfer between two other '
    'members',
    (tester) async {
      const groupId = 'g1';
      const members = [
        Member(id: 'm1', name: 'Alice'),
        Member(id: 'm2', name: 'Bob'),
      ];
      const group = Group(id: groupId, name: 'Trip', members: members);
      const key = (token: _token, groupId: groupId);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            invitePreviewProvider(_token).overrideWith(
              (ref) async => const InvitePreview(
                memberName: 'Bob',
                expired: false,
                claimed: false,
              ),
            ),
            inviteGroupsProvider(_token).overrideWith((ref) async => [group]),
            inviteGroupTransfersProvider(key).overrideWith(
              (ref) async => [
                const Transfer(from: 'm1', to: 'm2', amount: 20),
              ],
            ),
            inviteGroupExpensesProvider(
              key,
            ).overrideWith((ref) async => []),
          ],
          child: const ShadApp(
            home: Scaffold(body: InviteScreen(token: _token)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The transfer involves Bob (the invited member), so it still renders
      // as "Pending" — just without a "Settle up" tap target, since the
      // guest viewer never matches either side of the transfer.
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Settle up'), findsNothing);
    },
  );

  testWidgets(
    'suppresses the ghost-invite button on a transfer involving a ghost '
    'member',
    (tester) async {
      const groupId = 'g1';
      const members = [
        Member(id: 'm1', name: 'Alice'),
        Member(id: 'm2', name: 'Ghosty', isGhost: true),
      ];
      const group = Group(id: groupId, name: 'Trip', members: members);
      const key = (token: _token, groupId: groupId);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            invitePreviewProvider(_token).overrideWith(
              (ref) async => const InvitePreview(
                memberName: 'Ghosty',
                expired: false,
                claimed: false,
              ),
            ),
            inviteGroupsProvider(_token).overrideWith((ref) async => [group]),
            inviteGroupTransfersProvider(key).overrideWith(
              (ref) async => [
                const Transfer(from: 'm1', to: 'm2', amount: 20),
              ],
            ),
            inviteGroupExpensesProvider(
              key,
            ).overrideWith((ref) async => []),
          ],
          child: const ShadApp(
            home: Scaffold(body: InviteScreen(token: _token)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Invite'), findsNothing);
    },
  );

  testWidgets(
    'shows the balance card and only pending settlements involving the '
    'invited member',
    (tester) async {
      const groupId = 'g1';
      const members = [
        Member(id: 'm1', name: 'Alice'),
        Member(id: 'm2', name: 'Bob'),
        Member(id: 'm3', name: 'Carol'),
      ];
      const group = Group(id: groupId, name: 'Trip', members: members);
      const key = (token: _token, groupId: groupId);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            invitePreviewProvider(_token).overrideWith(
              (ref) async => const InvitePreview(
                memberName: 'Bob',
                expired: false,
                claimed: false,
              ),
            ),
            inviteGroupsProvider(_token).overrideWith((ref) async => [group]),
            inviteGroupTransfersProvider(key).overrideWith(
              (ref) async => [
                // Involves Bob (the invited member) — should show.
                const Transfer(from: 'm1', to: 'm2', amount: 20),
                // Doesn't involve Bob — should be filtered out entirely.
                const Transfer(from: 'm1', to: 'm3', amount: 10),
              ],
            ),
            inviteGroupExpensesProvider(
              key,
            ).overrideWith((ref) async => []),
          ],
          child: const ShadApp(
            home: Scaffold(body: InviteScreen(token: _token)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Bob's balance"), findsOneWidget);
      expect(find.text('Owes'), findsOneWidget);
      expect(find.text('Is owed'), findsOneWidget);

      expect(find.text('1 pending'), findsOneWidget);
      expect(find.text('Alice to Bob'), findsOneWidget);
      expect(find.text('Alice to Carol'), findsNothing);
    },
  );

  testWidgets(
    "shows a zero balance and no pending settlements when the invited "
    "member's name doesn't match anyone in the group",
    (tester) async {
      const groupId = 'g1';
      const members = [
        Member(id: 'm1', name: 'Alice'),
        Member(id: 'm2', name: 'Bob'),
      ];
      const group = Group(id: groupId, name: 'Trip', members: members);
      const key = (token: _token, groupId: groupId);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            invitePreviewProvider(_token).overrideWith(
              (ref) async => const InvitePreview(
                memberName: 'Sam Lee',
                expired: false,
                claimed: false,
              ),
            ),
            inviteGroupsProvider(_token).overrideWith((ref) async => [group]),
            inviteGroupTransfersProvider(key).overrideWith(
              (ref) async => [
                const Transfer(from: 'm1', to: 'm2', amount: 20),
              ],
            ),
            inviteGroupExpensesProvider(
              key,
            ).overrideWith((ref) async => []),
          ],
          child: const ShadApp(
            home: Scaffold(body: InviteScreen(token: _token)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Sam Lee's balance"), findsOneWidget);
      expect(find.text('All settled'), findsOneWidget);
    },
  );

  testWidgets(
    "'Create account to join' replaces the invite route instead of "
    'stacking on top of it — main.dart\'s router redirect decides where '
    'to send a freshly signed-in user by checking the *current* route, '
    'so a pushed route (which leaves that unchanged) would never let the '
    'post-signup redirect to home fire',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/invites/$_token',
        routes: [
          GoRoute(
            path: '/invites/:token',
            builder: (context, state) => Scaffold(
              body: InviteScreen(token: state.pathParameters['token']!),
            ),
          ),
          GoRoute(
            path: '/sign-up',
            builder: (context, state) =>
                const Scaffold(body: Text('Sign up screen')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            invitePreviewProvider(_token).overrideWith(
              (ref) async => const InvitePreview(
                memberName: 'Sam Lee',
                expired: false,
                claimed: false,
              ),
            ),
            inviteGroupsProvider(_token).overrideWith((ref) async => []),
          ],
          child: ShadApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create account to join'));
      await tester.pumpAndSettle();

      expect(find.text('Sign up screen'), findsOneWidget);
      expect(
        Navigator.of(tester.element(find.text('Sign up screen'))).canPop(),
        isFalse,
        reason:
            'the invite route must be replaced, not pushed underneath — '
            'otherwise it stays the router\'s "current" location forever',
      );
    },
  );
}
