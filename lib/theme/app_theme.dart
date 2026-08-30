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
    // shadcn_ui's own default theme draws a focused input's outer ring at
    // `radius.add(radius / 2)` (1.5x) — at our radius that reads as visibly
    // more rounded than the input itself. Match it to the input's own
    // radius instead so the ring hugs the same shape.
    decoration: ShadDecoration(
      secondaryFocusedBorder: ShadBorder.all(
        width: 2,
        color: AppColors.primary,
        radius: BorderRadius.circular(AppRadii.md),
        offset: 4,
      ),
    ),
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
    // Fully pill-shaped, like every button — shadcn_ui's own default theme
    // otherwise hardcodes the active-tab indicator to a 4px radius while the
    // track uses the app-wide radius, which visibly mismatches.
    tabsTheme: ShadTabsTheme(
      decoration: ShadDecoration(
        color: AppColors.surface,
        border: ShadBorder.all(
          radius: BorderRadius.circular(AppRadii.pill),
          width: 0,
        ),
      ),
      tabDecoration: ShadDecoration(
        border: ShadBorder.all(
          radius: BorderRadius.circular(AppRadii.pill),
          width: 0,
        ),
      ),
    ),
  );
}
