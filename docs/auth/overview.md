# Auth & identity

Firebase Auth (email/password) is the app's identity provider. It was
chosen over alternatives like Clerk because its Flutter SDK
(`firebase_auth`) is first-party and mature, whereas Clerk's is
community-maintained and was beta at the time. It's used purely for
identity — no other Firebase product is in play.

For the wire-level contract (headers, error codes, member provisioning
endpoint), see [`backend.md`](backend.md). This page covers the client-side
feature: screens, session state, and route guarding.

## Sign-up / sign-in

`AuthScreen` (`lib/screens/auth/auth_screen.dart`) handles both modes
(`AuthMode.login` / `AuthMode.signUp`) with the app's standard shadcn_ui
form patterns. Firebase Auth errors are mapped to per-field messages by
[`mapFirebaseAuthErrorCode`](../../lib/utils/auth_error.dart) (e.g.
`wrong-password` → a password-field error, `email-already-in-use` → an
email-field error) so the form can show a targeted message instead of a
raw Firebase exception, and so the mapping is unit-testable without
constructing a real `FirebaseAuthException`.

## Session state

`authStateProvider` (`lib/providers/auth_provider.dart`) is a
`StreamProvider<User?>` over `FirebaseAuth.authStateChanges()` — the single
source of truth for "is anyone signed in." `MyApp`
(`lib/main.dart`) watches it directly to decide what to render before
`go_router` is even involved:

- Still resolving → `SplashScreen`.
- Signed in, but the backend `Member` (below) hasn't resolved yet →
  `SplashScreen`.
- Signed in, but fetching the `Member` failed →
  `MemberProvisioningErrorScreen`, with a retry button that
  `ref.invalidate(currentMemberProvider)`s.
- Otherwise → the real `ShadApp.router`.

## Member provisioning

Being signed into Firebase isn't enough on its own — every domain
operation (creating a group, logging an expense) needs a backend `Member`.
`currentMemberProvider` (`lib/providers/current_member_provider.dart`)
bridges the two: once `authStateProvider` resolves to a non-null `User`, it
calls `GET /members/me`, a **get-or-create** endpoint that provisions a
`Member` row for this Firebase identity on first call and returns the
existing one on every call after. Every other provider that needs "the
current member" (`groupRepositoryProvider`,
`expenseRepositoryProvider`, `settlementRepositoryProvider`, ...) is
`Provider.autoDispose` and reads `currentMemberProvider.value`, resolving
to `null` (not throwing) whenever there's no member yet — see
[`../architecture.md`](../architecture.md#providers) and
[`../known-bugs/state-error-exception.md`](../known-bugs/state-error-exception.md)
for why that matters.

A freshly-provisioned `Member` has `name == Member.placeholderName` ("New
member"). `SetNameScreen` (`lib/screens/onboarding/set_name_screen.dart`)
catches that case right after sign-up (or on any later launch where the
name is still the placeholder) and asks for a real name; saving there
updates **both** the Firebase user's `displayName` and the backend
`Member` via `NameForm`.

## Route guarding

`go_router`'s `redirect` callback delegates to the pure function
[`resolveAuthRedirect`](../../lib/utils/auth_redirect.dart), given:

- `isSignedIn` — from `authRepositoryProvider.currentUser != null`.
- `isAuthRoute` — whether the target is `/sign-in` or `/sign-up`.
- `needsName` — `member != null && member.name == Member.placeholderName`.
- `isOnboardingNameRoute` — whether the target is `/onboarding/name`.
- `isMemberLoading` — `currentMemberProvider`'s `AsyncValue.isLoading`.

Resulting rules: signed-out users get bounced to `/sign-in` unless already
on an auth route; signed-in users on an auth route get bounced to `/`;
signed-in users who still need a name get sent to
`/onboarding/name`, then from there to `/onboarding/group` once named.

`isMemberLoading` exists specifically to cover sign-in-after-sign-out:
Riverpod notifies `go_router`'s `refreshListenable` synchronously as part
of its own internal provider-graph flush, which runs a full widget-tree
layer above `MyApp`. Without this gate, that flush can trigger a redirect
to `/` — building `HomeScreen` off a stale, already-signed-out `Member` of
`null` — before `MyApp`'s own splash-screen check ever gets to rebuild,
flashing an empty home screen.

## Scope

This is entirely client-side identity. See
[`backend.md`](backend.md#scope--whats-not-covered) for what the backend
side does and doesn't verify.
