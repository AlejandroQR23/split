import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../providers/auth_provider.dart';
import '../../providers/current_member_provider.dart';
import '../../providers/push_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/navigation/screen_header.dart';
import '../../widgets/profile/settings_row_card.dart';
import '../../widgets/shared/avatar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final member = ref.watch(currentMemberProvider).value;
    final email = ref.watch(authStateProvider).value?.email ?? '';

    if (member == null) return const SizedBox.shrink();

    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.background),
      child: Column(
        children: [
          const ScreenHeader(title: 'Perfil', isMainScreen: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: AppSpacing.xxxl * 2,
              ),
              children: [
                ShadCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      Avatar(name: member.name, radius: 40),
                      const SizedBox(height: AppSpacing.md),
                      Text(member.name, style: theme.textTheme.h3),
                      const SizedBox(height: AppSpacing.xs),
                      Text(email, style: theme.textTheme.muted),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: ShadButton(
                          onPressed: () => context.push('/profile/edit'),
                          child: const Text('Editar perfil'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _InviteFriendsCard(onTap: () {}),
                const SizedBox(height: AppSpacing.xl),
                SettingsRowCard(
                  title: 'Preferencias',
                  subtitle: 'Gestiona tus avisos de gastos y recordatorios.',
                  onTap: () => context.push('/profile/preferences'),
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ShadButton.ghost(
                    leading: const HugeIcon(
                      icon: HugeIcons.strokeRoundedLogout01,
                    ),
                    onPressed: () => signOutAndUnregisterDevice(ref),
                    child: const Text('Cerrar sesión'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteFriendsCard extends StatelessWidget {
  const _InviteFriendsCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: ShadCard(
        backgroundColor: AppColors.secondaryTint,
        border: ShadBorder.none,
        shadows: const [],
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Invita a tus amigos', style: theme.textTheme.h4),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Comparte Manu y queden a manu.',
                    style: theme.textTheme.muted,
                  ),
                ],
              ),
            ),
            const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01),
          ],
        ),
      ),
    );
  }
}
