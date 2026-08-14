import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '/widgets/navigation/floating_nav_bar.dart';

class ScreenScaffold extends StatelessWidget {
  final StatefulNavigationShell child;

  const ScreenScaffold({super.key, required this.child});

  static const List<FloatingNavItem> items = [
    FloatingNavItem(icon: LucideIcons.house, label: 'Home'),
    FloatingNavItem(icon: LucideIcons.users, label: 'Groups'),
  ];

  void onTap(int index) {
    child.goBranch(index, initialLocation: index == child.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          child,
          Align(
            alignment: Alignment.bottomCenter,
            child: FloatingNavBar(
              items: items,
              currentIndex: child.currentIndex,
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}
