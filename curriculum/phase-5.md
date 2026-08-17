# Phase 5: Algorithm & testing

## Approach

The debt-simplification algorithm is the conceptual heart of the app, and
deliberately has nothing to do with Flutter — it's a pure Dart function that
takes a group's expenses and produces the minimum set of transfers needed to
settle every balance. Because it's pure logic with no widgets, no
repository, and no I/O, it's also the first thing in this app worth testing
directly, and the best place in the curriculum to practice `flutter_test` in
isolation from UI concerns.

## Libraries / tools used this phase

- `flutter_test` — [docs](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html)

## Required knowledge

Concepts from the graph in overview.md this phase assumes or introduces:

- **Dart classes & language basics** (assumed) — [docs](https://dart.dev/language)
- **Immutable data models** (assumed) — [docs](https://dart.dev/language/constructors)
- **Pure algorithm design** (introduced) — [docs](https://dart.dev/language)
- **Unit testing with `flutter_test`** (introduced) — [docs](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html)

## Features

### 5.1 Algoritmo de simplificación de deudas (your idea)

What it does: given a group's list of expenses (each with a payer and a set
of people it's split between), computes each member's net balance, then
greedily matches debtors against creditors to produce the smallest possible
list of "who pays whom, how much" transfers that settles the group.
Concept(s) exercised: Pure algorithm design — [docs](https://dart.dev/language).

No code. No step-by-step implementation instructions here — this is a
conceptual spec, not a recipe. The reader still has to work out the how.

Think about: how do you get from "a list of expenses" to "one net number per
member" — what does that intermediate representation look like? Once you
have net balances, what does "greedy matching" mean concretely — at each
step, which debtor and which creditor do you pick, and why does repeatedly
picking the largest amounts on each side tend to minimize the number of
transfers? How do you know the algorithm is done — what's the terminating
condition?

### 5.2 Tests unitarios del algoritmo (your idea)

What it does: a `flutter_test` suite exercising 5.1's algorithm against a
range of scenarios — a group that's already settled, a simple two-person
debt, a multi-person chain of debts, and rounding edge cases from splitting
an amount that doesn't divide evenly.
Concept(s) exercised: Unit testing with `flutter_test` — [docs](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html).

No code. No step-by-step implementation instructions here — this is a
conceptual spec, not a recipe. The reader still has to work out the how.

Think about: for each scenario, what's the actual assertion — is it "the
exact list of transfers matches," or something looser like "every member's
balance is zero after applying the returned transfers"? Which of those is
more robust to the algorithm's exact tie-breaking choices? What's the
smallest input that would expose a rounding bug in an uneven split?

## Checklist

- [x] 5.1 Algoritmo de simplificación de deudas
- [x] 5.2 Tests unitarios del algoritmo
