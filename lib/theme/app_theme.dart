import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Assembles the design tokens into a [ShadThemeData]. This is the only
/// file that should construct [ShadThemeData] — everything else should
/// read tokens from [AppColors], [AppTypography], [AppSpacing]/[AppRadii]/
/// [AppShadows].
abstract class AppTheme {
  AppTheme._();

  /// The app's only theme — light only, no dark mode.
  static final ShadThemeData light = ShadThemeData(
    brightness: Brightness.light,
    colorScheme: AppColors.lightScheme,
    textTheme: AppTypography.textTheme,
    radius: BorderRadius.circular(AppRadii.md),
    primaryButtonTheme: const ShadButtonTheme(
      backgroundColor: AppColors.primary,
      hoverBackgroundColor: AppColors.primaryDark,
      pressedBackgroundColor: AppColors.primaryDark,
      foregroundColor: AppColors.primaryForeground,
      hoverForegroundColor: AppColors.primaryForeground,
      pressedForegroundColor: AppColors.primaryForeground,
    ),
    secondaryButtonTheme: const ShadButtonTheme(
      backgroundColor: AppColors.surface,
      hoverBackgroundColor: AppColors.border,
      pressedBackgroundColor: AppColors.border,
      foregroundColor: AppColors.ink,
      hoverForegroundColor: AppColors.ink,
      pressedForegroundColor: AppColors.ink,
    ),
    cardTheme: ShadCardTheme(
      backgroundColor: AppColors.background,
      shadows: AppShadows.card,
    ),
  );
}
