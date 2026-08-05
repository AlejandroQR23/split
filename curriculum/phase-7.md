# Phase 7: Polish — `flutter_animate` & transitions

## Approach

The app is functionally complete after Phase 6; this phase is entirely about
the micro-interactions the spec calls out explicitly — loading skeletons,
list fade/slide-ins, and screen transitions — plus turning Phase 6's balance
reveal from "animated" into the intended "wow moment." Everything here
builds on Phase 6's animation fundamentals but reaches for `flutter_animate`
as the higher-level tool for chaining effects without hand-rolling
controllers for every widget.

## Libraries / tools used this phase

- `flutter_animate` — [docs](https://pub.dev/packages/flutter_animate)
- `go_router` (custom transitions) — [docs](https://pub.dev/packages/go_router)

## Required knowledge

Concepts from the graph in overview.md this phase assumes or introduces:

- **Implicit/explicit Flutter animations** (assumed) — [docs](https://docs.flutter.dev/ui/animations)
- **`flutter_animate` effect chains** (introduced) — [docs](https://pub.dev/packages/flutter_animate)
- **Custom page transitions & loading skeletons** (introduced) — [docs](https://pub.dev/packages/go_router)

## Features

### 7.1 Micro-interacciones con flutter_animate (your idea)

What it does: applies `flutter_animate` effect chains (fade/slide-in) to the
items in the group list and expense history lists, so content appears with
motion instead of popping in instantly.
Concept(s) exercised: `flutter_animate` effect chains — [docs](https://pub.dev/packages/flutter_animate).

No code. No step-by-step implementation instructions here — this is a
conceptual spec, not a recipe. The reader still has to work out the how.

Think about: for a list of items appearing together, does each item need its
own delay to read as a staggered sequence rather than a single simultaneous
fade? What's the smallest, most natural motion for a list item — does it
need both fade and slide, or is one enough to read as intentional rather
than distracting?

### 7.2 Loading skeletons (your idea, evolving 2.2)

What it does: replaces Phase 2's plain loading state with skeleton
placeholders shaped like the eventual content, shown while the mock
repository's simulated delay is in progress.
Concept(s) exercised: Custom page transitions & loading skeletons — [docs](https://pub.dev/packages/go_router).

No code. No step-by-step implementation instructions here — this is a
conceptual spec, not a recipe. The reader still has to work out the how.

Think about: should the skeleton be a separate widget that mimics the real
content's layout, or can the real content widget itself render a "skeleton
mode"? How do you make the skeleton-to-content swap itself feel smooth
rather than an abrupt cut?

### 7.3 Transiciones entre pantallas y momento "wow" en balance (your idea)

What it does: custom go_router page transitions (fade/slide) between
screens, plus a final animation flourish on Phase 6's balance screen that
combines `flutter_animate` effects to make the debt-simplification reveal
the app's intended standout moment.
Concept(s) exercised: Custom page transitions & loading skeletons,
`flutter_animate` effect chains — [docs](https://pub.dev/packages/go_router).

No code. No step-by-step implementation instructions here — this is a
conceptual spec, not a recipe. The reader still has to work out the how.

Think about: where does a custom transition get configured for a go_router
route, and does every route need the same transition or should some differ
(e.g., the balance screen deserves something more dramatic than a plain
push)? What combination of effects on the balance screen would make it feel
like a distinct "moment" rather than just more of the same list animation
from 7.1?

## Checklist

- [ ] 7.1 Micro-interacciones con flutter_animate
- [ ] 7.2 Loading skeletons
- [ ] 7.3 Transiciones entre pantallas y momento "wow" en balance
