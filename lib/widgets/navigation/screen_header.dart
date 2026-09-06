import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:go_router/go_router.dart';

import '/theme/app_spacing.dart';
import '/theme/app_typography.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  final bool isMainScreen;
  final Widget? trailing;
  final bool showBackButton;

  const ScreenHeader({
    super.key,
    required this.title,
    this.isMainScreen = false,
    this.trailing,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(
        top: 0,
        bottom: AppSpacing.lg,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
      ),
      child: isMainScreen
          ? Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(title, style: AppTypography.screenTitle),
                  ),
                ),
                ?trailing,
              ],
            )
          : IntrinsicHeight(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (showBackButton)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ShadIconButton.ghost(
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowLeft01,
                          color: theme.colorScheme.foreground,
                        ),
                        onPressed: () => context.pop(),
                      ),
                    ),
                  Text(title, style: AppTypography.textTheme.h4),
                  if (trailing != null)
                    Align(alignment: Alignment.centerRight, child: trailing),
                ],
              ),
            ),
    );
  }
}
