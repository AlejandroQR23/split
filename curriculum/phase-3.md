# Phase 3: Navigation

## Approach

With a real (if mock) data layer in place, the app needs more than one
screen to actually be an app. This phase introduces go_router — declarative,
URL-shaped routing — and uses it to connect the group list to a per-group
detail screen. The interesting part isn't "add a second screen," it's
passing a specific group's identity through the route itself, so the detail
screen knows _which_ group's expenses to show.

## Libraries / tools used this phase

- `go_router` — [docs](https://pub.dev/packages/go_router)

## Required knowledge

Concepts from the graph in overview.md this phase assumes or introduces:

- **Flutter widget tree** (assumed) — [docs](https://docs.flutter.dev/ui/widgets-intro)
- **Declarative routing with go_router** (introduced) — [docs](https://pub.dev/packages/go_router)

## Features

### 3.1 Detalle de grupo con historial de gastos (your idea)

What it does: tapping a group in the list navigates to a detail screen for
that specific group, showing its expense history. The detail screen is
reached via a go_router route that carries the group's identity as a path
parameter, and it uses the same repository/provider layer from Phase 2 to
fetch that group's expenses.
Concept(s) exercised: Declarative routing with go_router — [docs](https://pub.dev/packages/go_router).

No code. No step-by-step implementation instructions here — this is a
conceptual spec, not a recipe. The reader still has to work out the how.

Think about: what should the route pattern look like so a group's ID is part
of the URL/path rather than passed as an opaque object? Once the detail
screen has that ID, how does it turn "an ID" into "this group's expenses" —
does the repository need a new method for that, or can the existing one be
filtered? What should happen if someone navigates to a group ID that doesn't
exist?

## Checklist

- [x] 3.1 Detalle de grupo con historial de gastos
