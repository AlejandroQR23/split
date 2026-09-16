import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/invite.dart';
import '../../providers/auth_provider.dart';
import '../../providers/current_member_provider.dart';
import '../../providers/groups_provider.dart';
import '../../providers/invite_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../utils/network_exception.dart';
import '../../widgets/invites/invite_groups_list.dart';

class InviteScreen extends ConsumerWidget {
  const InviteScreen({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previewAsync = ref.watch(invitePreviewProvider(token));

    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.background),
      child: SafeArea(
        child: previewAsync.when(
          loading: () => const _InviteLoading(),
          error: (error, stackTrace) => const _InviteInvalidState(
            message: "This invite link isn't valid.",
          ),
          data: (preview) {
            if (preview.expired) {
              return const _InviteInvalidState(
                message: 'This invite has expired — ask for a new link.',
              );
            }
            if (preview.claimed) {
              return const _InviteInvalidState(
                message: 'This invite has already been used.',
              );
            }
            return _InviteContent(token: token, preview: preview);
          },
        ),
      ),
    );
  }
}

class _InviteLoading extends StatelessWidget {
  const _InviteLoading();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Center(
      child: CircularProgressIndicator(color: theme.colorScheme.primary),
    );
  }
}

class _InviteInvalidState extends StatelessWidget {
  const _InviteInvalidState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedCancel01,
              color: theme.colorScheme.mutedForeground,
              size: 32,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.p,
            ),
          ],
        ),
      ),
    );
  }
}

class _InviteContent extends ConsumerWidget {
  const _InviteContent({required this.token, required this.preview});

  final String token;
  final InvitePreview preview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final groupsAsync = ref.watch(inviteGroupsProvider(token));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xxl,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("You're invited", style: AppTypography.screenTitle),
              const SizedBox(height: AppSpacing.xs),
              Text(
                "Browsing ${preview.memberName}'s groups.",
                style: theme.textTheme.muted,
              ),
            ],
          ),
        ),
        Expanded(
          child: groupsAsync.when(
            loading: () => const _InviteLoading(),
            error: (error, stackTrace) => _InviteInvalidState(
              message:
                  error is NetworkException &&
                      error.error.code == 'unauthenticated'
                  ? 'This invite has expired — ask for a new link.'
                  : "This invite link isn't valid.",
            ),
            data: (groups) => InviteGroupsList(
              token: token,
              groups: groups,
              invitedMemberName: preview.memberName,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: _InviteClaimCta(token: token, preview: preview),
        ),
      ],
    );
  }
}

class _InviteClaimCta extends ConsumerWidget {
  const _InviteClaimCta({required this.token, required this.preview});

  final String token;
  final InvitePreview preview;

  Future<void> _joinWithThisAccount(BuildContext context, WidgetRef ref) async {
    final email =
        ref.read(authRepositoryProvider).currentUser?.email ?? 'your account';
    final confirmed = await showShadSheet<bool>(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        return ShadSheet(
          useSafeArea: false,
          padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset),
          title: const Text('Join with this account?'),
          description: Text(
            "This merges ${preview.memberName}'s expense history into "
            '$email and adds you to their group(s).',
          ),
          actions: [
            ShadButton.outline(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ShadButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Join'),
            ),
          ],
          child: const SizedBox(height: AppSpacing.sm),
        );
      },
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      await ref.read(inviteRepositoryProvider).claimInvite(token);
    } catch (error) {
      if (!context.mounted) return;
      final message = error is NetworkException
          ? error.error.message
          : error.toString();
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('Could not join'),
          description: Text(message),
        ),
      );
      ref.invalidate(invitePreviewProvider(token));
      return;
    }

    ref.invalidate(groupsProvider);
    ref.invalidate(currentMemberProvider);
    if (!context.mounted) return;
    context.go('/');
  }

  void _createAccountToJoin(BuildContext context, WidgetRef ref) {
    ref.read(pendingInviteTokenProvider.notifier).state = token;
    context.go('/sign-up');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSignedIn = ref.watch(authStateProvider).value != null;

    return SizedBox(
      width: double.infinity,
      child: ShadButton(
        onPressed: () => isSignedIn
            ? _joinWithThisAccount(context, ref)
            : _createAccountToJoin(context, ref),
        child: Text(
          isSignedIn ? 'Join with this account' : 'Create account to join',
        ),
      ),
    );
  }
}
