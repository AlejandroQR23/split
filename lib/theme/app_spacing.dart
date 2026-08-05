import 'package:flutter/widgets.dart';

import 'app_colors.dart';

/// Spacing scale, 4pt base.
abstract class AppSpacing {
  AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;
}

/// Corner radii. [md] is the app-wide default (buttons, inputs, chips);
/// [lg] is used for cards/sheets; [pill] for fully-rounded shapes like the
/// floating nav bar.
abstract class AppRadii {
  AppRadii._();

  static const sm = 8.0;
  static const md = 10.0;
  static const lg = 14.0;
  static const xl = 20.0;
  static const pill = 999.0;
}

/// Shadow tokens. Tinted with [AppColors.ink] rather than pure black so
/// shadows read as part of the same palette.
abstract class AppShadows {
  AppShadows._();

  /// Subtle lift for cards and surfaces resting on the background.
  static final card = [
    BoxShadow(
      color: AppColors.ink.withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// Elevated float for the bottom navigation bar.
  static final nav = [
    BoxShadow(
      color: AppColors.ink.withValues(alpha: 0.10),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}
