# Phase 6: Balance screen & animation fundamentals

## Approach

Phase 5 produced the algorithm; this phase gives it a screen. The balance
screen is the app's "wow moment" per the spec, and getting there starts with
Flutter's own animation primitives — before reaching for `flutter_animate`
in Phase 7, it's worth understanding what an `AnimationController` and a
`Tween` actually do, since that's what `flutter_animate` is a convenience
layer over.

## Libraries / tools used this phase

- Flutter animation APIs — [docs](https://docs.flutter.dev/ui/animations)

## Required knowledge

Concepts from the graph in overview.md this phase assumes or introduces:

- **Flutter widget tree** (assumed) — [docs](https://docs.flutter.dev/ui/widgets-intro)
- **Layout widgets** (assumed) — [docs](https://docs.flutter.dev/ui/layout)
- **Implicit/explicit Flutter animations** (introduced) — [docs](https://docs.flutter.dev/ui/animations)

## Features

### 6.1 Pantalla de balance (your idea)

What it does: a screen that runs Phase 5's algorithm against the current
group's expenses and displays the resulting transfers — who pays whom, and
how much — animating them into view in sequence rather than all at once, so
the "who owes who" reveal reads as a moment rather than a static list.
Concept(s) exercised: Implicit/explicit Flutter animations — [docs](https://docs.flutter.dev/ui/animations).

No code. No step-by-step implementation instructions here — this is a
conceptual spec, not a recipe. The reader still has to work out the how.

Think about: does each transfer appearing need its own independent
animation, or one shared timeline that staggers them — and what's the
tradeoff? Where does the algorithm's output belong in the widget tree versus
where the animation state (which transfers have "appeared" so far) belongs?
What's the difference between reaching for an implicit animation widget here
versus needing an explicit `AnimationController` — which does a staggered
reveal actually require?

## Checklist

- [x] 6.1 Pantalla de balance
