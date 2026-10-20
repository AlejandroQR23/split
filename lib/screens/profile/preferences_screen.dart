import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../providers/notification_preferences_provider.dart';
import '../../providers/push_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/navigation/screen_header.dart';
import '../../widgets/shared/async_error_text.dart';

class PreferencesScreen extends ConsumerWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final preferences = ref.watch(notificationPreferencesProvider);
    final permission = ref.watch(notificationPermissionStatusProvider);
    final permissionDenied =
        permission.value == AuthorizationStatus.denied ||
        permission.value == AuthorizationStatus.notDetermined;

    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.background),
      child: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Preferencias'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  bottom: AppSpacing.xxxl * 2,
                ),
                children: [
                  Text('Notificaciones', style: theme.textTheme.large),
                  const SizedBox(height: AppSpacing.lg),
                  if (permissionDenied) ...[
                    const _PermissionDeniedBanner(),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  preferences.when(
                    skipError: true,
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stackTrace) => AsyncErrorText(error: error),
                    data: (prefs) => ShadCard(
                      backgroundColor: AppColors.background,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          ShadSwitch(
                            value: prefs.notifyNewExpense,
                            enabled: !permissionDenied,
                            onChanged: (value) => _update(
                              context,
                              ref,
                              notifyNewExpense: value,
                            ),
                            label: const Text('Nuevos gastos'),
                            sublabel: const Text(
                              'Te avisamos cuando alguien agregue un gasto que te incluye.',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          const ShadSeparator.horizontal(),
                          const SizedBox(height: AppSpacing.lg),
                          ShadSwitch(
                            value: prefs.notifyMonthlyReminder,
                            enabled: !permissionDenied,
                            onChanged: (value) => _update(
                              context,
                              ref,
                              notifyMonthlyReminder: value,
                            ),
                            label: const Text('Recordatorio mensual'),
                            sublabel: const Text(
                              'Una vez al mes te recordamos si tienes deudas pendientes.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _update(
    BuildContext context,
    WidgetRef ref, {
    bool? notifyNewExpense,
    bool? notifyMonthlyReminder,
  }) async {
    try {
      await ref
          .read(notificationPreferencesProvider.notifier)
          .updatePreference(
            notifyNewExpense: notifyNewExpense,
            notifyMonthlyReminder: notifyMonthlyReminder,
          );
    } catch (error) {
      if (!context.mounted) return;
      final message = error is Exception ? error.toString() : '$error';
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('No se pudo guardar el cambio'),
          description: Text(message),
        ),
      );
    }
  }
}

class _PermissionDeniedBanner extends StatelessWidget {
  const _PermissionDeniedBanner();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadCard(
      backgroundColor: AppColors.secondaryTint,
      border: ShadBorder.none,
      shadows: const [],
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notificaciones desactivadas', style: theme.textTheme.h4),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'El sistema está bloqueando las notificaciones de Manu. '
            'Actívalas desde la configuración de tu teléfono para usar '
            'estos avisos.',
            style: theme.textTheme.muted,
          ),
        ],
      ),
    );
  }
}
