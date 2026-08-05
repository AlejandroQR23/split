# CLAUDE.md

Guidance for Claude Code (and any other coding agent) working in this repo.

## What this project is

**Split** is a group-expense-splitting app (think Splitwise): groups of
people log what they paid and who it's split between, and the app nets out
balances and reduces them to the minimum number of transfers needed to
settle up.

It doubles as a **Flutter + Riverpod learning project** — the app is being
built incrementally by following a phased curriculum, not implemented all at
once. See `curriculum/` below before assuming what should exist yet.

## Stack

Flutter + Dart. Key packages: `shadcn_ui` (UI components/theming),
`flutter_riverpod` (state), `go_router` (navigation), `flutter_animate`
(animation), `google_fonts` (Plus Jakarta Sans). `image_picker` is planned
but not yet added.

## Required reading before writing any UI

**[`docs/design-system.md`](docs/design-system.md)** — the single source of
truth for colors, typography, spacing, radii, shadows, and component usage.
Read it before adding or editing any widget. The short version: two brand
anchors (emerald `#4CB963` primary, ink `#0C1618` text), light theme only,
Plus Jakarta Sans, and **never hardcode a visual value** — everything comes
from `lib/theme/*.dart` tokens. If a UI change needs a value that doesn't
exist yet, add it to the relevant token file rather than inlining it.

## Required reading before adding app features

**[`curriculum/overview.md`](curriculum/overview.md)** — the learning plan
this app is being built against. It defines:

- The concept graph (what Flutter/Riverpod concepts build on which)
- The phase breakdown, each detailed in `curriculum/phase-N.md`:

| Phase | Theme                                   | Doc                                 |
| ----- | --------------------------------------- | ----------------------------------- |
| 0     | Setup / project config                  | [phase-0.md](curriculum/phase-0.md) |
| 1     | Dart & Flutter fundamentals             | [phase-1.md](curriculum/phase-1.md) |
| 2     | State management & repository pattern   | [phase-2.md](curriculum/phase-2.md) |
| 3     | Navigation                              | [phase-3.md](curriculum/phase-3.md) |
| 4     | UI components, forms & media            | [phase-4.md](curriculum/phase-4.md) |
| 5     | Algorithm & testing                     | [phase-5.md](curriculum/phase-5.md) |
| 6     | Balance screen & animation fundamentals | [phase-6.md](curriculum/phase-6.md) |
| 7     | Polish: `flutter_animate` & transitions | [phase-7.md](curriculum/phase-7.md) |

Each phase file has a checklist (`- [ ]` / `- [x]`) tracking what's actually
been implemented — **check the relevant phase file's checklist before
assuming a feature, model, provider, or screen exists.** Work phase by
phase; don't jump ahead to a later phase's concepts (e.g. don't wire
`go_router` navigation before Phase 3, don't add the settle-up algorithm
before Phase 5) unless the user explicitly asks for it.

## Working in this repo

- `flutter analyze` — must be clean before considering work done.
- `flutter pub get` — after any `pubspec.yaml` change.
- No project-specific run/test skill exists yet; use standard `flutter run`
  / `flutter test`.
