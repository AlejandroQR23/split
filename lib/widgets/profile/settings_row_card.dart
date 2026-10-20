import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// A tappable title/subtitle/chevron row for the Profile tab.
class SettingsRowCard extends StatelessWidget {
  const SettingsRowCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: ShadCard(
        backgroundColor: AppColors.background,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.h4),
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle, style: theme.textTheme.muted),
                ],
              ),
            ),
            const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01),
          ],
        ),
      ),
    );
  }
}
