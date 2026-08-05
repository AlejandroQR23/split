# Phase 2: State management & repository pattern

## Approach

Phase 1's group list was hardcoded — fine for learning widgets, but nothing
like how the real app needs to work. This phase introduces the two ideas
that make the rest of the app possible: a repository boundary (`SplitRepository`)
that hides *where* data comes from behind an interface, with a mock
implementation behind it for now; and Riverpod, which lets widgets read that
repository's data reactively without manually threading it through
constructors. By the end of this phase, the Phase 1 screen is rebuilt to
watch a provider instead of reading a hardcoded list, and has real (if
simple) loading/error states.

## Libraries / tools used this phase

- `flutter_riverpod` — [docs](https://riverpod.dev)

## Required knowledge

Concepts from the graph in overview.md this phase assumes or introduces:

- **Ephemeral state & `setState`** (assumed, as a contrast point — riverpod
  exists to handle state `setState` can't) — [docs](https://docs.flutter.dev/data-and-backend/state-mgmt/ephemeral-vs-app)
- **Riverpod providers** (introduced) — [docs](https://riverpod.dev/docs/concepts2/providers)
- **Riverpod consumers** (introduced) — [docs](https://riverpod.dev/docs/concepts2/consumers)
- **Repository pattern** (introduced) — [docs](https://dart.dev/language/classes)
- **Wiring a repository through a Riverpod provider** (introduced) — [docs](https://riverpod.dev/docs/concepts2/providers)

## Features

### 2.1 Repositorio de grupos vía Riverpod (your idea, evolving 1.1)

What it does: replaces Phase 1's hardcoded group list with a proper
`SplitRepository` abstraction (an interface) and a mock implementation that
returns the same kind of data. The group list screen stops holding data
itself and instead watches a Riverpod provider that exposes the repository's
data.
Concept(s) exercised: Repository pattern, Riverpod providers, Riverpod
consumers, wiring a repository through a provider — [docs](https://riverpod.dev/docs/concepts2/providers).

No code. No step-by-step implementation instructions here — this is a
conceptual spec, not a recipe. The reader still has to work out the how.

Think about: what methods does `SplitRepository` need to expose for "get all
groups" to be useful later for "get one group's expenses" too? Why does the
interface living separately from the mock implementation matter — what would
change if you swapped the mock for a real backend later? Which Riverpod
provider type fits "expose a repository instance" versus "expose the data
that repository returns"?

### 2.2 Estado de carga simple (suggested)

What it does: the mock repository simulates a real data source by
introducing an artificial delay before returning its group list; the group
list screen handles the resulting loading and (hypothetical) error states
explicitly, rather than assuming data is always instantly available. This
exists to give Phase 7's skeleton-loader polish something real to attach to
— without it, there's no loading state to make beautiful later.
Concept(s) exercised: Riverpod providers (async data), Riverpod consumers — [docs](https://riverpod.dev/docs/concepts2/providers).

No code. No step-by-step implementation instructions here — this is a
conceptual spec, not a recipe. The reader still has to work out the how.

Think about: what does Riverpod give you for representing "data that isn't
here yet, might still error" as a single value a widget can react to? How
does the group list screen need to branch its build method to handle "still
loading" vs. "here's the data" vs. "something went wrong" — even if, for
now, that branching is visually plain?

## Checklist

- [ ] 2.1 Repositorio de grupos vía Riverpod
- [ ] 2.2 Estado de carga simple
