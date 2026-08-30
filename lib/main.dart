import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/expenses/add_expense_screen.dart';
import 'screens/groups/create_group_screen.dart';
import 'screens/groups/edit_group_screen.dart';
import 'screens/groups/group_details_screen.dart';
import 'screens/groups/group_list_screen.dart';
import 'screens/home/home_screen.dart';
import 'theme/app_theme.dart';
import 'utils/auth_redirect.dart';
import 'utils/go_router_refresh_stream.dart';
import 'widgets/navigation/screen_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _homeShellNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _groupsShellNavigatorKey =
    GlobalKey<NavigatorState>();

const _authRoutes = {'/sign-in', '/sign-up'};

final routerProvider = Provider<GoRouter>((ref) {
  final refreshStream = GoRouterRefreshStream(
    ref.watch(authRepositoryProvider).authStateChanges(),
  );
  ref.onDispose(refreshStream.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: refreshStream,
    redirect: (context, state) {
      final isSignedIn = ref.read(authRepositoryProvider).currentUser != null;
      final isAuthRoute = _authRoutes.contains(state.matchedLocation);
      return resolveAuthRedirect(
        isSignedIn: isSignedIn,
        isAuthRoute: isAuthRoute,
      );
    },
    routes: [
      GoRoute(
        path: '/sign-in',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            const AuthScreen(initialMode: AuthMode.login),
      ),
      GoRoute(
        path: '/sign-up',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            const AuthScreen(initialMode: AuthMode.signUp),
      ),
      GoRoute(
        path: '/add-expense',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          return AddExpenseScreen(
            groupId: state.uri.queryParameters['groupId'],
          );
        },
      ),
      GoRoute(
        path: '/groups/new',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateGroupScreen(),
      ),
      GoRoute(
        path: '/groups/group/:groupId/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            EditGroupScreen(groupId: state.pathParameters['groupId']!),
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
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    if (authState.isLoading) {
      return ShadApp(
        title: 'Split',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        themeMode: ThemeMode.light,
        home: const _SplashScreen(),
      );
    }

    return ShadApp.router(
      routerConfig: ref.watch(routerProvider),
      title: 'Split',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ColoredBox(
      color: theme.colorScheme.background,
      child: Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      ),
    );
  }
}
