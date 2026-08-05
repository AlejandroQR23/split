import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Raw color tokens for the app.
///
/// Everything here is derived from two brand anchors: [primary] (emerald)
/// and [ink] (near-black text). Neutrals (surface/border/mutedForeground)
/// are tints of [ink] mixed with white, so the whole palette shares one
/// undertone. Change the anchors here and the rest of the app follows,
/// via [AppColors.lightScheme].
abstract class AppColors {
  AppColors._();

  // Brand anchors ------------------------------------------------------
  static const primary = Color(0xFF4CB963);
  static const ink = Color(0xFF0C1618);

  // Primary ramp --------------------------------------------------------
  static const primaryForeground = Color(0xFFFFFFFF);

  /// Pressed/hover state for primary surfaces.
  static const primaryDark = Color(0xFF3F9A52);

  /// Light emerald surface: active nav pill, badges, selection highlight.
  static const primaryTint = Color(0xFFE8F6EC);

  // Neutrals (tints of `ink` mixed with white) --------------------------
  static const background = Color(0xFFFFFFFF);

  /// Muted fill / secondary button background.
  static const surface = Color(0xFFF5F6F6);

  /// Secondary/caption text.
  static const mutedForeground = Color(0xFF6D7577);

  /// Borders, dividers, input outlines.
  static const border = Color(0xFFE5E8E8);

  // Status ---------------------------------------------------------------
  static const destructive = Color(0xFFE5484D);
  static const destructiveForeground = Color(0xFFFFFFFF);

  /// The app's shadcn color scheme. Light only — this app has no dark theme.
  ///
  /// Built from [ShadZincColorScheme.light] so every field shadcn expects is
  /// populated by sane defaults, overriding only the brand-relevant ones.
  static const lightScheme = ShadZincColorScheme.light(
    background: background,
    foreground: ink,
    card: background,
    cardForeground: ink,
    popover: background,
    popoverForeground: ink,
    primary: primary,
    primaryForeground: primaryForeground,
    secondary: surface,
    secondaryForeground: ink,
    muted: surface,
    mutedForeground: mutedForeground,
    accent: primaryTint,
    accentForeground: ink,
    destructive: destructive,
    destructiveForeground: destructiveForeground,
    border: border,
    input: border,
    ring: primary,
    selection: primaryTint,
  );
}
