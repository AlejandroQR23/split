import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'screens/group_list_screen.dart';
import 'theme/app_theme.dart';

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
      home: const Scaffold(body: GroupListScreen()),
    );
  }
}
