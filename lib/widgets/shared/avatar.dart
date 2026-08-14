import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../theme/app_colors.dart';

/// A circular avatar showing a person's initial, derived from the first
/// character of [name] (e.g. "You" or a member's name).
///
/// Pass [ringColor] to draw a border around the avatar — used when several
/// avatars overlap (see [RecentGroupsSection]'s avatar stack) so each one
/// stays visually distinct from the one behind it.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.name,
    this.radius = 18,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
    this.ringColor,
  });

  final String name;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;
  final Color? ringColor;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    final circle = CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? AppColors.surface,
      child: Text(
        initial,
        style: (textStyle ?? theme.textTheme.large).copyWith(
          color: foregroundColor ?? theme.colorScheme.mutedForeground,
        ),
      ),
    );

    if (ringColor == null) return circle;

    return CircleAvatar(
      radius: radius + 2,
      backgroundColor: ringColor,
      child: circle,
    );
  }
}
