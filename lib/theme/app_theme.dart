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

  /// Every button variant is fully pill-shaped, regardless of the app-wide
  /// [AppRadii.md] radius used for inputs/chips — matches the brand
  /// reference, where buttons are stadium-shaped and cards are just
  /// generously rounded.
  static final _pillButtonDecoration = ShadDecoration(
    border: ShadBorder.all(radius: BorderRadius.circular(AppRadii.pill)),
  );

  /// The app's only theme — light only, no dark mode.
  static final ShadThemeData light = ShadThemeData(
    brightness: Brightness.light,
    colorScheme: AppColors.lightScheme,
    textTheme: AppTypography.textTheme,
    radius: BorderRadius.circular(AppRadii.md),
    primaryButtonTheme: ShadButtonTheme(
      backgroundColor: AppColors.primary,
      hoverBackgroundColor: AppColors.primaryDark,
      pressedBackgroundColor: AppColors.primaryDark,
      foregroundColor: AppColors.primaryForeground,
      hoverForegroundColor: AppColors.primaryForeground,
      pressedForegroundColor: AppColors.primaryForeground,
      decoration: _pillButtonDecoration,
    ),
    secondaryButtonTheme: ShadButtonTheme(
      backgroundColor: AppColors.surface,
      hoverBackgroundColor: AppColors.border,
      pressedBackgroundColor: AppColors.border,
      foregroundColor: AppColors.ink,
      hoverForegroundColor: AppColors.ink,
      pressedForegroundColor: AppColors.ink,
      decoration: _pillButtonDecoration,
    ),
    destructiveButtonTheme: ShadButtonTheme(decoration: _pillButtonDecoration),
    outlineButtonTheme: ShadButtonTheme(decoration: _pillButtonDecoration),
    ghostButtonTheme: ShadButtonTheme(decoration: _pillButtonDecoration),
    cardTheme: ShadCardTheme(
      backgroundColor: AppColors.background,
      radius: BorderRadius.circular(AppRadii.lg),
      shadows: AppShadows.card,
    ),
  );
}
