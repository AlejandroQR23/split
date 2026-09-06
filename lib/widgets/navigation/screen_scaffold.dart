import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '/widgets/navigation/floating_nav_bar.dart';

class ScreenScaffold extends StatelessWidget {
  final StatefulNavigationShell child;

  const ScreenScaffold({super.key, required this.child});

  static const List<FloatingNavItem> items = [
    FloatingNavItem(icon: HugeIcons.strokeRoundedHome01, label: 'Home'),
    FloatingNavItem(icon: HugeIcons.strokeRoundedUserGroup, label: 'Groups'),
    FloatingNavItem(icon: HugeIcons.strokeRoundedUser, label: 'Profile'),
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
