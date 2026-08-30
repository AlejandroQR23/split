/// Decides where `go_router` should send the user, given sign-in state and
/// whether they're already on a sign-in/sign-up route. Kept independent of
/// `go_router`/Riverpod types so it's trivially unit-testable. Returns null
/// to allow the originally requested route through unchanged.
String? resolveAuthRedirect({
  required bool isSignedIn,
  required bool isAuthRoute,
}) {
  if (!isSignedIn && !isAuthRoute) return '/sign-in';
  if (isSignedIn && isAuthRoute) return '/';
  return null;
}
