# Split

## Overview

Split is a group-expense-splitting app (think Splitwise): groups of people
log what they paid and who it's split between, and the app nets out
balances and reduces them to the minimum number of transfers needed to
settle up.

It doubles as a Flutter + Riverpod learning project — the app is being
built incrementally by following a phased curriculum (see `curriculum/`)
rather than implemented all at once. Each phase introduces a new set of
Flutter/Riverpod concepts on top of the ones before it.

## Stack

Flutter + Dart.

| Package           | Why                                                                                      |
| ------------------ | ----------------------------------------------------------------------------------------- |
| `flutter_riverpod`  | State management and the repository pattern the app's data layer is built around.       |
| `go_router`         | Declarative navigation between screens.                                                 |
| `shadcn_ui`         | UI component library the app's design system (`docs/design-system.md`) is built on top of. |
| `google_fonts`      | Loads Plus Jakarta Sans, the app's typeface.                                            |
| `flutter_animate`   | Higher-level effect-chaining API for polish animations (fades, slides) without hand-rolling a controller for every widget. |
| `collection`        | Value-based list comparison (`ListEquality`), used where list *content* needs to be compared rather than list *identity*. |
| `cupertino_icons`   | Default Flutter icon set. |

## Phase 0: Setup / project config

Brought the project from the default `flutter create` counter-app template
to the real stack: added `flutter_riverpod`, `go_router`, `shadcn_ui`,
`flutter_animate`, `google_fonts`, and `collection` to `pubspec.yaml`,
cleared out the counter boilerplate, and split `lib/` into `models/`,
`repositories/`, `providers/`, `screens/`, `widgets/`, and `theme/`
folders — the same folders every later phase builds into. No feature logic
happens in this phase; it's just one working, empty app on top of the
right dependencies and structure.

## Phase 1: Dart & Flutter fundamentals

The first group list is built directly against a hardcoded, in-memory list
of `Group`/`Member` objects — no repository, no Riverpod, no navigation.
`Group` and `Member` are marked `@immutable` (`lib/models/`) from the
start, even though nothing in this phase actually requires it: Phase 2
swaps the hardcoded list for a repository that hands the same objects out
to multiple widgets at once, and immutability is what guarantees none of
those widgets can mutate shared state out from under another one.

## Phase 2: State management & repository pattern

`GroupRepository` (`lib/repositories/group_repository.dart`) is an
abstract interface with a single `GroupRepositoryImpl` mock behind it, so
the group list screen depends on "something that can fetch/add/remove/
update groups" rather than the mock directly — swapping in a real backend
later means writing one new implementation, not touching any screen.

The repository is wired up through an `AsyncNotifier`
(`GroupsNotifier` in `lib/providers/groups_provider.dart`,
mirrored by `ExpensesNotifier` for expenses) rather than a plain
`FutureProvider`. A `FutureProvider` only exposes read-only async data,
which is enough for "fetch and display" — but this repository also needs
`addGroup`/`removeGroup`/`updateGroup`, and the UI needs to see the
refreshed list right after a write succeeds. `AsyncNotifier` gives those
mutation methods a home on the same object that owns the async state. A
shared `_mutateAndRefresh` helper re-fetches after a successful mutation
and, on a failed one, falls back to the previous known-good state instead
of an error state — so a failed write doesn't blow away a screen that was
already showing good data.

The repository's artificial `Future.delayed` (`delayDuration`) exists
specifically to give the screen a real loading state to branch on
(`AsyncData` / `AsyncLoading` / `AsyncError`) rather than data that's
always instantly available — without it there'd be nothing for Phase 7's
skeleton loaders to attach to later.

## Phase 3: Navigation

Routing (`lib/main.dart`) uses `go_router`'s
`StatefulShellRoute.indexedStack` for the Home/Groups tabs instead of a
flat list of `GoRoute`s. The indexed-stack shell keeps each tab's own
navigation stack alive independently, so switching Groups → Home → Groups
doesn't reset how deep you'd navigated into Groups. The group detail route
(`/groups/group/:groupId`) carries the group's id as a path parameter
rather than passing the `Group` object through route state — the detail
screen re-fetches by id through the same `groupsProvider` from Phase 2, so
it works the same whether it's reached by tapping a card or by restoring a
deep link. `/add-expense` sits outside the tab shell as a top-level route
(via a separate `parentNavigatorKey`), since adding an expense is a
modal-like task rather than a tab destination.

## Phase 4: UI components, forms & media

The add-expense form (`lib/widgets/expenses/add_expense_form.dart`) is
built from shadcn_ui's `ShadForm` / `ShadInputFormField` /
`ShadSelectFormField`, with a `validator` per field rather than one
submit-time check, so an empty concept, a non-positive amount, and an
unselected group each report inline. "Paid by" and "split between" reuse
the same `MemberSelector` widget with a `multiSelect` flag instead of two
separate widgets — both are fundamentally "pick some subset of this
group's members," differing only in whether the selection is capped at
one.

The photo-attachment part of this phase (`image_picker`) hasn't been
implemented yet — the dependency isn't in `pubspec.yaml` and the form has
no photo field — which is why 4.1 is still unchecked in
`curriculum/phase-4.md` despite the rest of the form being functional.

## Phase 5: Algorithm & testing

`computeTransfers` (`lib/helpers/compute_settlements.dart`) is pure Dart
with no Flutter/Riverpod imports, split into two steps: `computeBalance`
nets each member to a single signed number (what they paid minus what they
owe across every expense), then `simplifyDebts` greedily matches the
biggest creditor against the biggest debtor, repeatedly, using two
`PriorityQueue`s rather than re-sorting a list on every iteration.
Balances are compared against an `epsilon` (0.005) rather than `== 0.0`,
since summing/splitting doubles accumulates floating-point drift that
would otherwise leave "settled" members with a non-zero balance.

`compute_settlements_test.dart` mostly asserts invariants rather than
exact transfer lists — after applying the returned transfers, every
balance should net to ~0, no transfer should be smaller than `epsilon`,
and total transferred should equal total owed. Exact-output assertions
would be brittle against the greedy algorithm's tie-breaking order (which
creditor/debtor pair it happens to match first when amounts are equal);
"debts are settled" is the actual requirement, so that's what's tested.

`computeSettlements` is a separate function from `computeTransfers` —
same underlying balances, but netted against one specific member (the
current user) and aggregated per counterparty rather than reduced to a
minimal transfer set. It's what the home screen's "you owe / you're owed"
summary and per-person settlement rows are built from, where the transfer
graph itself doesn't matter, only "what does *this* person owe or get
owed, and for what."

## Phase 6: Balance screen & animation fundamentals

The staggered reveal on the balance/settlement lists (pending settlements,
spending history, recent activity) is built on a hand-rolled
`AnimationController` + `Interval` abstraction (`RevealAnimationState`)
rather than reaching for `flutter_animate`, which was already available.
Two behaviors this phase specifically needed aren't things `flutter_animate`
gives you for free:

- **A fixed total reveal duration.** The whole reveal always finishes in
  the same amount of time (500ms) no matter how many items are in the
  list — each item's own on-screen window is a proportional slice
  (`Interval`) of that fixed budget, rather than a fixed per-item delay
  that would make the total reveal time grow with the list length.
- **Restart only on a real data change.** The reveal replays when the
  underlying list's *content* actually changes (compared via
  `ListEquality` against each item's value equality), not on every
  incidental rebuild of the parent widget.

Building this by hand — rather than using the higher-level package — was
also the point of this phase: understanding what an `AnimationController`
and `Interval` actually do before Phase 7 hides them behind a convenience
API.

## Phase 7: Polish — `flutter_animate` & transitions

Everywhere else that just needed a one-off fade or slide when content
first appears — the group list on the home screen and the full groups
list screen — uses `flutter_animate`'s `.animate()` effect chains directly,
instead of extending Phase 6's `RevealAnimationState`. Those lists don't
need a fixed total duration or restart-on-change semantics; "play once
when it appears" is enough, and `flutter_animate` gets there in a single
chained call with no controller to create, dispose, or reason about.

`RevealAnimationState` earned its extra complexity in Phase 6 specifically
because it needed behavior `flutter_animate` doesn't provide out of the
box. Where that behavior isn't needed, `flutter_animate` is the simpler,
less error-prone tool for the job.
