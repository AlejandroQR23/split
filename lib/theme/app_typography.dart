import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'app_colors.dart';

/// Typography for the app: Plus Jakarta Sans across shadcn's whole type
/// scale, plus a small set of signature styles for the app's identity
/// moments (big amounts, screen titles, nav labels).
abstract class AppTypography {
  AppTypography._();

  /// The shadcn text theme, built on Plus Jakarta Sans.
  ///
  /// shadcn's default styles carry no color (it's applied ambiently from
  /// [AppColors.lightScheme].foreground), except `muted`, which we color
  /// explicitly here so `theme.textTheme.muted` always reads as secondary
  /// text without callers having to override it.
  static final ShadTextTheme textTheme = () {
    final base = ShadTextTheme.fromGoogleFont(GoogleFonts.plusJakartaSans);
    return base.copyWith(
      muted: base.muted.copyWith(color: AppColors.mutedForeground),
    );
  }();

  /// Large numeric display for balances/amounts.
  static final TextStyle amountDisplay = GoogleFonts.plusJakartaSans(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.6,
    color: AppColors.ink,
  );

  /// Page/screen header.
  static final TextStyle screenTitle = GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.ink,
  );

  /// Caption under nav bar icons.
  static final TextStyle navLabel = GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
}
