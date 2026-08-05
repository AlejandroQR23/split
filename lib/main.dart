import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'theme/app_colors.dart';
import 'theme/app_spacing.dart';
import 'theme/app_theme.dart';
import 'theme/app_typography.dart';
import 'widgets/floating_nav_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      title: 'Split',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      home: const HomeShowcasePage(),
    );
  }
}

/// Showcases the design system: typography, buttons, a card, and the
/// floating bottom nav bar, all driven purely by the tokens in `lib/theme/`.
class HomeShowcasePage extends StatefulWidget {
  const HomeShowcasePage({super.key});

  @override
  State<HomeShowcasePage> createState() => _HomeShowcasePageState();
}

class _HomeShowcasePageState extends State<HomeShowcasePage> {
  int _navIndex = 0;

  static const _navItems = [
    FloatingNavItem(icon: LucideIcons.house, label: 'Home'),
    FloatingNavItem(icon: LucideIcons.activity, label: 'Activity'),
    FloatingNavItem(icon: LucideIcons.users, label: 'Groups'),
    FloatingNavItem(icon: LucideIcons.user, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xxxl * 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overview', style: AppTypography.screenTitle),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Your balance', style: theme.textTheme.muted),
                  const SizedBox(height: AppSpacing.xs),
                  Text('\$1,240.00', style: AppTypography.amountDisplay),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      ShadButton(
                        leading: const Icon(LucideIcons.plus, size: 16),
                        onPressed: () {},
                        child: const Text('Add expense'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ShadButton.secondary(
                        onPressed: () {},
                        child: const Text('Settle up'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ShadCard(
                    title: Text('Trip to Lisbon', style: theme.textTheme.h4),
                    description: const Text('4 members · 12 expenses'),
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(
                        'You are owed \$86.50',
                        style: theme.textTheme.p.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingNavBar(
              items: _navItems,
              currentIndex: _navIndex,
              onTap: (index) => setState(() => _navIndex = index),
            ),
          ),
        ],
      ),
    );
  }
}
