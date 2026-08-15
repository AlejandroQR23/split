import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'screens/expenses/add_expense_screen.dart';
import 'screens/groups/group_details_screen.dart';
import 'screens/groups/group_list_screen.dart';
import 'screens/home/home_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/navigation/screen_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _homeShellNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _groupsShellNavigatorKey =
    GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: [
    GoRoute(
      path: '/add-expense',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        return AddExpenseScreen(groupId: state.uri.queryParameters['groupId']);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScreenScaffold(child: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _homeShellNavigatorKey,
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _groupsShellNavigatorKey,
          routes: [
            GoRoute(
              path: '/groups',
              builder: (context, state) => const GroupListScreen(),
              routes: [
                GoRoute(
                  path: 'group/:groupId',
                  builder: (context, state) {
                    final groupId = state.pathParameters['groupId']!;
                    return GroupDetailsScreen(groupId: groupId);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.router(
      routerConfig: _router,
      title: 'Split',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
    );
  }
}
