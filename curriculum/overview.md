# Split Demo — Learning Overview

## What we're building

Split Demo is a group-expense-splitting app: groups of people log what they
paid and who it's split between, and the app nets out balances and reduces
them to the minimum number of transfers needed to settle up. It's a good
vehicle for learning Flutter + Riverpod specifically because it forces every
major layer of the stack to show up for a real reason — a data model that
has to stay consistent across screens, a repository boundary that has to be
swappable (mock now, real backend later), navigation with real path
parameters (a specific group, not just "next screen"), forms with several
interacting fields, an algorithm that's pure logic worth testing in
isolation, and a payoff screen (balances) that only feels good with real
animation work.

The declared boilerplate (models, mock repository, providers, router,
screens, algorithm + tests) does not actually exist in `lib/` yet — only the
default `flutter create` counter app is there, and `pubspec.yaml` only lists
`flutter`, `cupertino_icons`, and `flutter_lints`. This curriculum builds
everything from Phase 0 onward; nothing is assumed pre-existing.

## Tool / stack

- **Flutter** — [official docs](https://docs.flutter.dev)
- **Dart** — [official docs](https://dart.dev)
- **Riverpod** (`flutter_riverpod`) — [official docs](https://riverpod.dev)
- **go_router** — [pub.dev](https://pub.dev/packages/go_router)
- **shadcn_ui** (`shadcn_ui`, Flutter port of shadcn/ui) — [docs](https://flutter-shadcn-ui.mariuti.com)
- **flutter_animate** — [pub.dev](https://pub.dev/packages/flutter_animate)
- **image_picker** — [pub.dev](https://pub.dev/packages/image_picker)
- **flutter_test** — [official docs](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html)

## Concept graph

Every concept this curriculum teaches, in prerequisite order. Concept B
depends on concept A if you need A to understand B. This is the graph the
phase breakdown below is derived from — don't re-derive it per phase.

| # | Concept | Depends on | Doc link |
|---|---------|------------|----------|
| 1 | Dart classes & language basics | — | [docs](https://dart.dev/language) |
| 2 | Flutter widget tree (Stateless/StatefulWidget, build) | 1 | [docs](https://docs.flutter.dev/ui/widgets-intro) |
| 3 | Layout widgets (Row/Column/ListView/Expanded) | 2 | [docs](https://docs.flutter.dev/ui/layout) |
| 4 | Immutable data models (constructors, copyWith, equality) | 1 | [docs](https://dart.dev/language/constructors) |
| 5 | Ephemeral state & `setState` | 2 | [docs](https://docs.flutter.dev/data-and-backend/state-mgmt/ephemeral-vs-app) |
| 6 | Riverpod providers | 5 | [docs](https://riverpod.dev/docs/concepts2/providers) |
| 7 | Riverpod consumers (`ConsumerWidget`, `ref.watch`/`ref.read`) | 6 | [docs](https://riverpod.dev/docs/concepts2/consumers) |
| 8 | Repository pattern (abstract interface + mock implementation) | 4 | [docs](https://dart.dev/language/classes) |
| 9 | Wiring a repository through a Riverpod provider | 6, 8 | [docs](https://riverpod.dev/docs/concepts2/providers) |
| 10 | Declarative routing with go_router (routes, path params) | 2 | [docs](https://pub.dev/packages/go_router) |
| 11 | shadcn_ui components & theming | 3 | [docs](https://flutter-shadcn-ui.mariuti.com) |
| 12 | Forms & validation | 11 | [docs](https://docs.flutter.dev/cookbook/forms/validation) |
| 13 | `image_picker` & async platform APIs (Future, async/await) | 1 | [docs](https://pub.dev/packages/image_picker) |
| 14 | Pure algorithm design (independent of UI) | 1, 4 | [docs](https://dart.dev/language) |
| 15 | Unit testing with `flutter_test` | 14 | [docs](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html) |
| 16 | Implicit/explicit Flutter animations | 2, 3 | [docs](https://docs.flutter.dev/ui/animations) |
| 17 | `flutter_animate` effect chains | 16 | [docs](https://pub.dev/packages/flutter_animate) |
| 18 | Custom page transitions & loading skeletons | 10, 17 | [docs](https://pub.dev/packages/go_router) |

## Phases

| Phase | Theme | Concepts covered | Doc |
|-------|-------|-------------------|-----|
| 0 | Setup / project config | — | [phase-0.md](phase-0.md) |
| 1 | Dart & Flutter fundamentals | 1, 2, 3, 4 | [phase-1.md](phase-1.md) |
| 2 | State management & repository pattern | 5, 6, 7, 8, 9 | [phase-2.md](phase-2.md) |
| 3 | Navigation | 10 | [phase-3.md](phase-3.md) |
| 4 | UI components, forms & media | 11, 12, 13 | [phase-4.md](phase-4.md) |
| 5 | Algorithm & testing | 14, 15 | [phase-5.md](phase-5.md) |
| 6 | Balance screen & animation fundamentals | 16 | [phase-6.md](phase-6.md) |
| 7 | Polish: `flutter_animate` & transitions | 17, 18 | [phase-7.md](phase-7.md) |
