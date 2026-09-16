# Known bug: `requireCurrentMemberProvider` StateError flash on sign-out

## Status: FIXED (2026-09-06)

Regression test: `test/main_test.dart` — "signing out while HomeScreen is
mounted, then back in, does not crash".

## Symptom (as reported)

After signing out and signing back in, the app briefly (~1 second) shows the
Riverpod red error screen:

```
══╡ EXCEPTION CAUGHT BY RIVERPOD ╞══════════════════════════════════════════
The following StateError was thrown:
Bad state: requireCurrentMemberProvider was read before
currentMemberProvider resolved a signed-in Member.
...
#6      ProviderScheduler._performRefresh (package:riverpod/src/core/scheduler.dart:196:37)
#7      ProviderScheduler._task (package:riverpod/src/core/scheduler.dart:168:5)
...
Another exception was thrown: ProviderException: Tried to use a provider that is in error state.
```

...then self-heals and the home screen renders correctly.

## Actual root cause (confirmed, not speculative)

**The crash happens the instant you sign out while a signed-in screen
(`HomeScreen`, `ProfileScreen`, `GroupDetailsScreen`, `EditProfileScreen`) is
still mounted — no second sign-in is needed to reproduce it.** A minimal
repro (in `test/main_test.dart`, currently red) is: sign in, let
`HomeScreen` render, then sign out. That alone throws.

The mechanism, confirmed by instrumenting a `ProviderObserver` and walking
the Riverpod 3.4.2 source (`~/.pub-cache/hosted/pub.dev/riverpod-3.4.2/`):

1. `flutter_riverpod`'s `ProviderScope` is implemented as
   `_UncontrolledProviderScopeState`, and its `build()` method calls
   `_callTask()` — which flushes Riverpod's **entire pending provider
   graph** (`ProviderScheduler._performRefresh`) — **before** it calls
   `super.build()`, i.e. before any descendant widget (including `MyApp`)
   gets to rebuild for that same frame.
2. When the user signs out, `authStateProvider` emits `null`, and
   `currentMemberProvider` (a `FutureProvider<Member?>`) recomputes to
   `null`.
3. At that exact moment, `requireCurrentMemberProvider` — a plain,
   **synchronous** `Provider<Member>` — is still "active" (it still has a
   listener) because `HomeScreen` is still mounted; unmounting `HomeScreen`
   only happens in the widget-build phase, which is the *next* step, not
   this one.
4. Riverpod's scheduler dutifully flushes every still-active provider that
   depends on the thing that changed. `requireCurrentMemberProvider`'s
   build callback re-runs, sees `member == null`, and throws its guard
   `StateError` — **by design**, that's what it's for.
5. Because `requireCurrentMemberProvider` is a plain sync `Provider<T>`
   (not `FutureProvider`/`AsyncNotifierProvider`), it has no `AsyncError`
   state to absorb the throw into. The exception propagates straight out of
   `ProviderElement.flush()` → `_performRefresh()` → `_task()` →
   `_callTask()` → **`ProviderScope.build()` itself** — i.e. it's not a
   contained per-widget error, it blows up the root of the widget tree.
6. Everything that transitively watches `requireCurrentMemberProvider`
   (`groupRepositoryProvider`, `expenseRepositoryProvider`,
   `settlementRepositoryProvider`, and their `AsyncNotifierProvider`s:
   `groupsProvider`, `recentGroupsProvider`, `allExpensesProvider`,
   `allSettlementsProvider`, `groupSettlementsProvider`) also gets flushed
   in the same pass and fails with `ProviderException: Tried to use a
   provider that is in error state`, cascading further.
7. Only *after* this whole flush finishes does Flutter's normal build phase
   run, at which point `MyApp`/`go_router` actually react to the sign-out
   and unmount `HomeScreen` — clearing the error. That's the ~1s flash.

Confirmed via a `ProviderObserver` timeline (`didAddProvider` /
`didUpdateProvider` / `providerDidFail` / `didUnmountProvider`) showing the
**same `Provider<Member>` instance** created during the original sign-in
transitioning straight to `null`/error at sign-out, well before any
unmount event fires.

### Why this was hard to pin down

The original hypothesis (before instrumenting `ProviderObserver`) was that
the crash happens on the **second sign-in** after a sign-out, because a
`container.exists(requireCurrentMemberProvider)` check right after sign-out
returned `false`, suggesting proper disposal. That was misleading: the
provider had already thrown-and-been-disposed *during the sign-out itself*,
earlier in the same test — the test just wasn't checking
`tester.takeException()` immediately after the sign-out step, so the
pending exception was only observed later, at the next `expect()` call
(after the second sign-in), wrongly implicating that step instead.

**Lesson: call `tester.takeException()` after every state transition you
care about, not just at the end** — otherwise an earlier exception gets
misattributed to a later one.

## What was tried, in order (with outcomes)

1. **`MyApp` gate: check `member.isLoading` instead of `!member.hasValue`**
   (`lib/main.dart`). Riverpod's `AsyncValue.copyWithPrevious` keeps
   `hasValue` true (with the *previous* value) during a reload, so the old
   `!member.hasValue` check was wrongly treating "still loading, showing
   stale data" as "resolved". Real bug, real fix, but **insufficient** —
   doesn't touch the crash above, which happens inside Riverpod's internal
   graph flush, upstream of anything `MyApp` renders.

2. **`autoDispose` on `requireCurrentMemberProvider` and everything that
   transitively watches it** (`current_member_provider.dart`,
   `groups_provider.dart`, `expenses_provider.dart`,
   `settlement_provider.dart`), so these session-scoped providers don't
   persist forever past sign-out (they previously were plain `Provider`/
   `AsyncNotifierProvider`, i.e. kept alive forever once created — a real,
   separate bug: cross-account data leakage, since a second user signing in
   on the same device would see the first user's cached groups/expenses
   until something happened to invalidate them). Verified via
   `container.exists()` that disposal does work correctly. **Necessary,
   independently valid, but insufficient** for this specific crash, since
   the crash fires *before* disposal even gets a chance to run (see root
   cause above).

3. **`go_router` redirect gate: added `isMemberLoading` param to
   `resolveAuthRedirect`** (`lib/utils/auth_redirect.dart`,
   `lib/main.dart`), so `go_router` won't navigate to a protected route
   while `currentMemberProvider` is still resolving. Real bug (found via
   the same investigation), real fix, but **also insufficient** for this
   crash — confirmed by re-running the repro test with this fix in place;
   identical failure, identical stack trace, identical two providers
   failing (verified with a `ProviderObserver`).

4. **Made `groupRepositoryProvider`, `expenseRepositoryProvider`,
   `settlementRepositoryProvider` nullable and watch `currentMemberProvider`
   directly instead of the throwing `requireCurrentMemberProvider`**, with
   their dependent `AsyncNotifier`s (`GroupsNotifier`, `RecentGroupsNotifier`,
   `AllExpensesNotifier`, `AllSettlementsNotifier`,
   `GroupSettlementsNotifier`) short-circuiting to `Future.value(const [])`
   when the repository is `null`. This is the approach the user approved
   ("expose as AsyncValue, short-circuit to empty"). **Implemented, but
   still insufficient on its own** — confirmed by re-running the repro
   test: it still fails, with the identical `StateError`, because...

5. **Not yet done:** `HomeScreen`, `ProfileScreen` (where the actual "Sign
   Out" button lives), `GroupDetailsScreen`, and `EditProfileScreen` all
   *directly* `ref.watch(requireCurrentMemberProvider)` at the widget level
   (not just transitively through the repository providers fixed in step
   4). Any one of these being mounted is, by itself, sufficient to keep
   `requireCurrentMemberProvider` "active" and trigger the exact same crash
   — completely independent of whether the provider layer (step 4) has
   been fixed. This was confirmed empirically: after applying fix 4, the
   repro test (sign in → let `HomeScreen` render → sign out) still fails
   with the same `StateError`, because `HomeScreen`'s own
   `ref.watch(requireCurrentMemberProvider)` (home_screen.dart:18) is
   itself an active listener.

## The fix

`requireCurrentMemberProvider` was **deleted**. It was a synchronous
`Provider<Member>` that could enter an invalid state as a *routine*
consequence of a normal user action (sign-out) — and a plain sync provider
has no error state to absorb that throw into, so it escaped straight out of
`ProviderScope.build()` and took down the root of the tree. The guard was
therefore not an assertion about "should never happen"; it was firing on an
expected transition.

Every consumer now watches the nullable `currentMemberProvider` directly and
degrades to an inert widget for the one transitional frame where it's
`null` — the same pattern already applied to the repository providers in
step 4 above. Concretely:

- `lib/screens/home/home_screen.dart`
- `lib/screens/profile/profile_screen.dart`
- `lib/screens/profile/edit_profile_screen.dart`
- `lib/screens/groups/group_details_screen.dart`

each now do `ref.watch(currentMemberProvider).value` and
`if (member == null) return const SizedBox.shrink();`. That frame is
immediately superseded by `go_router`'s redirect to `/sign-in`, so there's
no UX cost.

Fixes 1–4 from the list above are all retained: each addressed a real,
independent bug found during this investigation (stale-`hasValue` gate,
session-scoped providers leaking across accounts, redirecting into a
protected route mid-fetch, repositories watching a throwing provider).

### Why a centralized route guard was rejected

The "wrap every protected route in a guard widget" option in the original
open question **cannot work**, and it's worth recording why. A guard that
declines to build its child only takes effect during Flutter's build phase
— which runs *after* `ProviderScope.build()` has already flushed the
provider graph. During that flush the screen element is still mounted and
still a registered listener of the throwing provider, so the throw happens
before the guard ever gets a chance to skip the child. Listener
registration outlives the frame; only removing the throwing provider from
the reactive path fixes it.

## Verification

- `flutter analyze` — clean.
- `flutter test` — 43/43 pass, including the regression test, which now
  covers the full reported cycle: sign in → HomeScreen renders → sign out →
  sign back in as a different user → HomeScreen renders again, with
  `tester.takeException()` asserted `isNull` after every transition.

## Lessons worth keeping

1. **`tester.takeException()` after every state transition**, not just at
   the end — otherwise an earlier exception gets misattributed to a later
   step. This is what made the bug look like a "second sign-in" problem for
   most of the investigation when it was really a sign-out problem.
2. **A sync `Provider<T>` cannot represent a transient invalid state.** If a
   value can legitimately go missing during a normal transition, the
   provider must be nullable or async; a throwing guard turns a routine
   transition into a root-level crash.
3. Riverpod flushes its **entire** pending graph from inside
   `ProviderScope.build()`, before any descendant rebuilds. Anything still
   listening at that instant gets recomputed, whether or not the widget
   holding the listener is about to unmount.
