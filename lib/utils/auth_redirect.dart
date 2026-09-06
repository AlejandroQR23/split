/// Decides where `go_router` should send the user, given sign-in state,
/// whether a name is still needed post-signup, and which of those routes
/// they're already on. Kept independent of `go_router`/Riverpod types so
/// it's trivially unit-testable. Returns null to allow the originally
/// requested route through unchanged.
String? resolveAuthRedirect({
  required bool isSignedIn,
  required bool isAuthRoute,
  bool needsName = false,
  bool isOnboardingNameRoute = false,
}) {
  if (!isSignedIn && !isAuthRoute) return '/sign-in';
  if (isSignedIn && isAuthRoute) return '/';
  if (isSignedIn && needsName && !isOnboardingNameRoute) {
    return '/onboarding/name';
  }
  if (isSignedIn && !needsName && isOnboardingNameRoute) {
    return '/onboarding/group';
  }
  return null;
}
