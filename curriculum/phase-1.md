# Phase 1: Dart & Flutter fundamentals

## Approach

Before touching state management, routing, or any of the fancier stack
pieces, this phase is about the two most basic layers everything else sits
on: Dart's class system for representing data, and Flutter's widget tree for
turning that data into pixels. Everything built here is deliberately static
— hardcoded in-memory data, no repository abstraction, no navigation, no
Riverpod. The goal is a group list screen that *looks* real but is, under
the hood, about as simple as a Flutter screen can be.

## Libraries / tools used this phase

- Flutter widgets — [docs](https://docs.flutter.dev/ui/widgets-intro)
- Dart language basics — [docs](https://dart.dev/language)

## Required knowledge

Concepts from the graph in overview.md this phase assumes or introduces:

- **Dart classes & language basics** (introduced) — [docs](https://dart.dev/language)
- **Flutter widget tree** (introduced) — [docs](https://docs.flutter.dev/ui/widgets-intro)
- **Layout widgets** (introduced) — [docs](https://docs.flutter.dev/ui/layout)
- **Immutable data models** (introduced) — [docs](https://dart.dev/language/constructors)

## Features

### 1.1 Lista de grupos (your idea)

What it does: a screen that shows every group the (hypothetical) user
belongs to, each with its member names visible — the same feature described
in the app spec, but built here against a hardcoded, in-memory list rather
than any real data source.
Concept(s) exercised: Dart classes & language basics, Flutter widget tree,
Layout widgets, Immutable data models — [docs](https://docs.flutter.dev/ui/layout).

No code. No step-by-step implementation instructions here — this is a
conceptual spec, not a recipe. The reader still has to work out the how.

Think about: what does a `Group` need to hold to render both its name and
its member list? What does a `Member` need to hold? What makes these classes
"immutable" in Dart terms, and why would that matter later once this data
comes from a repository instead of a hardcoded list? What Flutter widget is
right for rendering a variable-length list of groups, versus a
fixed-length row of member chips inside one group card?

## Checklist

- [ ] 1.1 Lista de grupos (static, hardcoded data)
