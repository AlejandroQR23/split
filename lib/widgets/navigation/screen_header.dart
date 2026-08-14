import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:go_router/go_router.dart';

import '/theme/app_spacing.dart';
import '/theme/app_typography.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  final bool isMainScreen;

  const ScreenHeader({
    super.key,
    required this.title,
    this.isMainScreen = false,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMainScreen)
            ShadIconButton.ghost(
              icon: Icon(Icons.arrow_back, color: theme.colorScheme.foreground),
              onPressed: () => context.pop(),
            ),
          SizedBox(height: !isMainScreen ? 8.0 : 0),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              title,
              style: isMainScreen
                  ? AppTypography.screenTitle
                  : AppTypography.textTheme.h3,
            ),
          ),
        ],
      ),
    );
  }
}
