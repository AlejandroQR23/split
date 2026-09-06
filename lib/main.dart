import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'firebase_options.dart';
import 'models/member.dart';
import 'providers/auth_provider.dart';
import 'providers/current_member_provider.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/expenses/add_expense_screen.dart';
import 'screens/groups/create_group_screen.dart';
import 'screens/groups/edit_group_screen.dart';
import 'screens/groups/group_details_screen.dart';
import 'screens/groups/group_list_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/set_name_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/splash/member_provisioning_error_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'theme/app_theme.dart';
import 'utils/auth_redirect.dart';
import 'utils/go_router_refresh_stream.dart';
import 'widgets/navigation/screen_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _homeShellNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _groupsShellNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _profileShellNavigatorKey =
    GlobalKey<NavigatorState>();

const _authRoutes = {'/sign-in', '/sign-up'};
const _onboardingNameRoute = '/onboarding/name';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshStream = GoRouterRefreshStream(
    ref.watch(authRepositoryProvider).authStateChanges(),
  );
  ref.onDispose(refreshStream.dispose);
  ref.listen(currentMemberProvider, (_, _) => refreshStream.refresh());

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: refreshStream,
    redirect: (context, state) {
      final isSignedIn = ref.read(authRepositoryProvider).currentUser != null;
      final isAuthRoute = _authRoutes.contains(state.matchedLocation);
      final memberState = ref.read(currentMemberProvider);
      final member = memberState.value;
      final needsName = member != null && member.name == Member.placeholderName;
      return resolveAuthRedirect(
        isSignedIn: isSignedIn,
        isAuthRoute: isAuthRoute,
        needsName: needsName,
        isOnboardingNameRoute: state.matchedLocation == _onboardingNameRoute,
        isMemberLoading: memberState.isLoading,
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
        path: _onboardingNameRoute,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SetNameScreen(),
      ),
      GoRoute(
        path: '/onboarding/group',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            const CreateGroupScreen(isFirstGroup: true),
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
      GoRoute(
        path: '/profile/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScreenScaffold(child: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeShellNavigatorKey,
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
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
          StatefulShellBranch(
            navigatorKey: _profileShellNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
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
      return _shadApp(home: const SplashScreen());
    }

    if (authState.value != null) {
      final member = ref.watch(currentMemberProvider);

      if (member.isLoading) {
        return _shadApp(home: const SplashScreen());
      }
      if (member.hasError) {
        return _shadApp(
          home: MemberProvisioningErrorScreen(
            onRetry: () => ref.invalidate(currentMemberProvider),
          ),
        );
      }
    }

    return ShadApp.router(
      routerConfig: ref.watch(routerProvider),
      title: 'Split',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
    );
  }

  ShadApp _shadApp({required Widget home}) {
    return ShadApp(
      title: 'Split',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      home: home,
    );
  }
}
