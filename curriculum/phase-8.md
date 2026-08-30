# Phase 8: Real backend integration

## Approach

Every phase up to now has been built against a mock `GroupRepository` /
`ExpenseRepository` with an artificial delay standing in for network
latency. That was deliberate — Phase 2 put the repository interface behind
an abstraction specifically so the mock could be swapped for something real
without touching the screens above it. This phase makes that swap: the app
starts talking to the actual HTTP API documented in
[`docs/frontend-guide.md`](../docs/frontend-guide.md).

Two things fall out of this that aren't just "point the app at a URL."
First, real network calls fail in ways the mock never did — timeouts,
`404`s, `422` validation errors — and the existing loading/error states from
Phase 2 need to branch on real, typed failures instead of a hypothetical
one. Second, the API needs a `memberId` for every write (`X-User-Id`), but
the server generates ids — you can no longer hardcode `currentUser` as
`Member(id: 'me', ...)`. This phase closes that gap with a **bootstrap
identity**: a real `Member` created once on first launch and remembered
locally. It's a deliberate stepping stone, not a finished feature — Phase 9
replaces it with a real signed-in identity.

## Libraries / tools used this phase

- `http` — [pub.dev](https://pub.dev/packages/http)
- `shared_preferences` — [pub.dev](https://pub.dev/packages/shared_preferences)

## Required knowledge

Concepts from the graph in overview.md this phase assumes or introduces:

- **Repository pattern** (assumed) — [docs](https://dart.dev/language/classes)
- **Wiring a repository through a Riverpod provider** (assumed) — [docs](https://riverpod.dev/docs/concepts2/providers)
- **Pure algorithm design** (assumed, as a contrast point — see 8.4) — [docs](https://dart.dev/language)
- **HTTP client & REST integration** (introduced) — [docs](https://pub.dev/packages/http)
- **Mapping API errors to typed domain exceptions** (introduced) — [docs](https://pub.dev/packages/http)
- **Local key-value persistence** (introduced) — [docs](https://pub.dev/packages/shared_preferences)

## Features

### 8.1 Repositorios reales sobre la API HTTP (suggested, evolving 2.1)

What it does: replaces `GroupRepositoryImpl` and `ExpenseRepositoryImpl`'s
in-memory mock data with implementations that call the real API — `POST
/groups`, `GET /groups`, `POST /groups/{id}/expenses`, etc., per
`docs/frontend-guide.md`. The `GroupRepository`/`ExpenseRepository`
interfaces from Phase 2 don't change; only what implements them does, which
is the entire point of having drawn that boundary back then.
Concept(s) exercised: HTTP client & REST integration — [docs](https://pub.dev/packages/http).

No code. No step-by-step implementation instructions here — this is a
conceptual spec, not a recipe. The reader still has to work out the how.

Think about: the API's "write with ids, read with objects" convention means
a request body and its response don't have the same shape — how does that
affect the methods you write to serialize a `Group`/`Expense` for a request
versus parse one from a response? Where does the base URL live so it isn't
hardcoded in every method? Which existing repository methods no longer map
cleanly to one endpoint (for example, does `removeGroup` still make sense,
given the API's `DELETE /groups/{groupId}` also cascades expenses)?

### 8.2 Manejo de errores de red (suggested, evolving 2.2)

What it does: turns the API's `{ "error": { "code", "message" } }` shape
into typed exceptions the app can branch on, and extends Phase 2's
loading/error states from "hypothetical error" to real ones — a `404` on a
deleted group, a `422` when an expense's shares don't sum to its amount, a
dropped connection.
Concept(s) exercised: Mapping API errors to typed domain exceptions — [docs](https://pub.dev/packages/http).

No code. No step-by-step implementation instructions here — this is a
conceptual spec, not a recipe. The reader still has to work out the how.

Think about: should every `4xx`/`5xx` become one generic "something went
wrong" exception, or does the UI need to distinguish "this group doesn't
exist anymore" from "you can't remove this member, they have an open
balance" (`has_open_balance`)? What's the smallest set of exception types
that lets the UI show a genuinely different message per case, without a
`switch` on raw string error codes scattered through the widget layer?

### 8.3 Identidad de arranque persistente (suggested)

What it does: on first launch, creates a real `Member` via `POST /members`
and saves the returned id with `shared_preferences`; on every subsequent
launch, reads that saved id instead of creating a new one. This replaces
the hardcoded `currentUser` constant everywhere it's currently used as the
`X-User-Id` sent with requests.
Concept(s) exercised: Local key-value persistence — [docs](https://pub.dev/packages/shared_preferences).

No code. No step-by-step implementation instructions here — this is a
conceptual spec, not a recipe. The reader still has to work out the how.

Think about: this lookup is asynchronous and has to resolve before any
screen that needs `X-User-Id` can make a request — where in the app's
startup does that belong, and what should the UI show while it's
resolving? What happens if `shared_preferences` has an id saved but the
server no longer recognizes it (for example, a wiped database in
development) — does the app need to detect and recover from that, or is it
acceptable to fail loudly for now?

### 8.4 Balances y settlements calculados por el servidor (suggested, evolving 5.1, 6.1)

What it does: points the balance screen (Phase 6) at
`GET /groups/{groupId}/transfers` and `GET /members/{memberId}/settlements`
instead of Phase 5's local `compute_settlements.dart`. Balances are shared
state across every member of a group, so once other people's writes can
change them independently of this client, only the server has a
trustworthy view — the client can no longer be the source of truth for a
number other users' apps also display.
Concept(s) exercised: HTTP client & REST integration, Pure algorithm design
(as the contrast being resolved) — [docs](https://pub.dev/packages/http).

No code. No step-by-step implementation instructions here — this is a
conceptual spec, not a recipe. The reader still has to work out the how.

Think about: Phase 5's algorithm and its tests don't become wrong or
wasted — they're still the correct reference implementation, and a good
way to sanity-check the server's output in development. But should the
live balance screen ever fall back to computing locally, or is "always ask
the server, show a loading/error state otherwise" the simpler and more
correct choice once balances are multi-user data?

## Checklist

- [x] 8.1 Repositorios reales sobre la API HTTP
- [x] 8.2 Manejo de errores de red
- [ ] 8.3 Identidad de arranque persistente
- [x] 8.4 Balances y settlements calculados por el servidor
