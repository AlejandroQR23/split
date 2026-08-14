import 'package:flutter/widgets.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// One destination in a [FloatingNavBar].
class FloatingNavItem {
  const FloatingNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// A floating, pill-shaped bottom navigation bar.
///
/// Place it at the bottom of a [Stack]/[Scaffold] body, over the page
/// content, with some bottom padding on the scrollable content so it
/// doesn't sit under the bar. Built entirely from design tokens
/// ([AppColors], [AppSpacing], [AppRadii], [AppShadows]) — no hardcoded
/// styling.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  }) : assert(items.length >= 1, 'FloatingNavBar needs at least 1 item');

  final List<FloatingNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.nav,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.xs),
                  _NavItem(
                    item: items[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final FloatingNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.mutedForeground;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryTint : null,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 22, color: color),
            const SizedBox(width: AppSpacing.xs),
            Text(
              item.label,
              style: AppTypography.navLabel.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
