/// Decides where `go_router` should send the user, given sign-in state,
/// whether a name is still needed post-signup, and which of those routes
/// they're already on. Kept independent of `go_router`/Riverpod types so
/// it's trivially unit-testable. Returns null to allow the originally
/// requested route through unchanged.
///
/// [isMemberLoading] must be true whenever Firebase reports a signed-in
/// user but the backend `Member` fetch hasn't resolved yet. Without this
/// check, signing back in (after a sign-out) makes this redirect fire
/// before `MyApp`'s own splash-screen gate ever gets to rebuild — `go_router`
/// reacts to auth-state changes via a `ChangeNotifier` that Riverpod
/// notifies synchronously as part of its own internal graph flush, which
/// runs a whole widget-tree layer above `MyApp`. That flush would otherwise
/// navigate to `/` and build `HomeScreen` off a signed-out `Member` of
/// `null` still carried over from before the sign-in, flashing an empty
/// home screen before the real one.
String? resolveAuthRedirect({
  required bool isSignedIn,
  required bool isAuthRoute,
  bool needsName = false,
  bool isOnboardingNameRoute = false,
  bool isMemberLoading = false,
}) {
  if (!isSignedIn && !isAuthRoute) return '/sign-in';
  if (isSignedIn && isMemberLoading) return null;
  if (isSignedIn && isAuthRoute) return '/';
  if (isSignedIn && needsName && !isOnboardingNameRoute) {
    return '/onboarding/name';
  }
  if (isSignedIn && !needsName && isOnboardingNameRoute) {
    return '/onboarding/group';
  }
  return null;
}
