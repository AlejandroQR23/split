# Architecture

## Stack

| Package | Role |
| --- | --- |
| `flutter_riverpod` | State management — providers, `AsyncNotifier`, `autoDispose` |
| `go_router` | Declarative routing, incl. `StatefulShellRoute` for the bottom-nav tabs and redirect-based auth gating |
| `shadcn_ui` | UI component library the design system is built on (see [`design-system.md`](design-system.md)) |
| `flutter_animate` | Animation effect chains for polish (reveal animations, transitions) |
| `google_fonts` | Plus Jakarta Sans, loaded via the design system's typography tokens |
| `http` | REST client, wrapped by [`lib/api/http_client.dart`](../lib/api/http_client.dart) |
| `firebase_core` / `firebase_auth` | Identity — see [`auth/overview.md`](auth/overview.md) |
| `flutter_dotenv` | Loads `API_URL` and other config from a gitignored `.env` at startup |
| `flutter_confetti` | Celebration effect (settle-up flow) |
| `hugeicons`, plus `shadcn_ui`'s bundled Lucide icons | Iconography |

`shared_preferences` is still a `pubspec.yaml` dependency but is no longer
used anywhere in `lib/` — it backed a "bootstrap identity" that Firebase
Auth replaced (see [`auth/overview.md`](auth/overview.md)). Safe to remove
once nothing else needs it.

## App layers

```
lib/
  models/        immutable data classes (Member, Group, Expense, Transfer, Settlement) — fromJson only, no HTTP awareness
  repositories/  abstract interface + *Impl that calls the HTTP API
  providers/     Riverpod wiring: constructs repositories, exposes AsyncValue state to the UI
  screens/       one file per route/page
  widgets/       reusable, composable UI pieces used by more than one screen
  utils/         cross-cutting helpers (network errors, auth redirect logic, formatting)
  theme/         design tokens (see design-system.md)
  api/           the shared http.BaseClient wrapper
```

### Repository pattern

Every domain exposes an `abstract class` describing what operations exist,
and one `*Impl` that calls the real API:

```dart
abstract class GroupRepository {
  Future<List<Group>> fetchGroups();
  Future<void> addGroup(CreateGroupInput group);
  // ...
}

class GroupRepositoryImpl implements GroupRepository {
  GroupRepositoryImpl(this._client, this._userId);
  // ... calls http.Client methods against relative URIs
}
```

This boundary exists so the implementation can change (it already has once:
Phase 2's in-memory mock became Phase 8's real HTTP client) without
touching any screen or provider above it. New domain work should keep
extending the abstract interface rather than reaching around it.

### Providers

- **Read state** is `AsyncNotifier<List<T>>` (e.g. `GroupsNotifier`,
  `AllExpensesNotifier`), exposing `AsyncValue<List<T>>` to the UI.
- **Session-scoped repository providers** (`groupRepositoryProvider`,
  `expenseRepositoryProvider`, `settlementRepositoryProvider`) are
  `Provider.autoDispose<T?>` — they watch
  [`currentMemberProvider`](auth/overview.md) and resolve to `null` while
  there's no signed-in `Member`. Every dependent notifier's `build()` must
  treat a `null` repository as "no data yet" (`Future.value(const [])`),
  **not** throw — see
  [`known-bugs/state-error-exception.md`](known-bugs/state-error-exception.md)
  for why a throwing provider on this path once took down the whole app.
- **Mutations** go through a `_mutateAndRefresh` helper on the notifier:
  run the write, then refetch the list, keeping the previous value on the
  UI if only the refetch (not the write) fails. Errors `rethrow` past the
  notifier so the calling screen can catch them and show a toast (see
  Error handling below).

### Routing

`go_router` is configured once in [`lib/main.dart`](../lib/main.dart) with
a single `redirect` callback,
[`resolveAuthRedirect`](../lib/utils/auth_redirect.dart), kept as a pure
function of `(isSignedIn, isAuthRoute, needsName, isOnboardingNameRoute,
isMemberLoading)` so it's unit-testable without constructing `go_router` or
Riverpod types. The router's `refreshListenable` is a
`GoRouterRefreshStream` fed by Firebase's `authStateChanges()`, plus a
`ref.listen` on `currentMemberProvider` so a redirect re-evaluates the
instant the backend `Member` resolves — see
[`auth/overview.md`](auth/overview.md) for why `isMemberLoading` has to
gate this.

Main-tab navigation (`/`, `/groups`, `/profile`) is a
`StatefulShellRoute.indexedStack` so each tab keeps its own navigation
stack across tab switches.

## Error handling

- **Fetch errors** (loading a list): render via
  [`AsyncErrorText`](../lib/widgets/shared/async_error_text.dart).
- **Mutation errors** (create/update/delete): catch the `rethrow`n
  exception at the call site and show a `ShadToast`.

Both should ultimately branch on a typed `NetworkException` (see below)
rather than displaying a raw exception string, so the UI can distinguish
"this group doesn't exist anymore" from "you're not allowed to do that"
where the API gives it a distinct `code`.

## Backend integration conventions

These conventions are shared by every domain doc under `docs/` — each
domain page documents only what's specific to it.

### Base URL

`HttpClient` (`lib/api/http_client.dart`) resolves every request's relative
URI against `dotenv.env['API_URL']` via `Uri.resolveUri`. That uses RFC
3986 **merge** semantics: a base URL with no trailing slash (e.g.
`https://api.split.example.com/v1`) drops its last path segment before
appending, silently stripping `/v1` from every request. See
[`../todo.md`](../todo.md) for this as an open, unfixed bug — `API_URL`
must currently end in a trailing slash to work around it.

### Auth

Every authenticated request carries `Authorization: Bearer <Firebase ID
token>`, refreshed and retried once on a `401`/`unauthenticated` response
before signing the user out. **This superseded an earlier `X-User-Id`
header design** (client-trusted, unverified) once Phase 9 shipped —
anything you find describing `X-User-Id` is describing the pre-Phase-9
contract, not the current one. See [`auth/backend.md`](auth/backend.md)
for the full current model.

### IDs

All resource ids are server-generated strings. Clients never invent an id
for a resource they're creating — request bodies for `POST` omit `id`;
response bodies always include it.

### Dates

Every timestamp is **UTC**, ISO 8601 with a `Z` suffix
(`"2026-08-22T14:30:00Z"`). Localizing to a human-readable local time is
entirely a client concern — the server has no concept of a member's
timezone.

### Request/response shape

- `Content-Type: application/json` on every request with a body and every
  response.
- Field names are `camelCase`, matching Dart model fields 1:1.
- `POST` that creates a resource → `201 Created` with the full resource.
- `PATCH` is a **partial** update — omitted fields are left unchanged;
  returns `200 OK` with the full updated resource.
- `DELETE` → `204 No Content`.
- **Write with ids, read with objects**: a request body references another
  resource by its `id` (e.g. `paidById`, `memberIds`); the response embeds
  the full object (e.g. `paidBy`, `members`). The one exception is
  `Transfer.from`/`Transfer.to`, always bare ids — see
  [`balances/overview.md`](balances/overview.md).

### Error shape

Every non-2xx response:

```json
{
  "error": {
    "code": "not_found",
    "message": "Human-readable description",
    "details": { "...": "optional, error-specific" }
  }
}
```

Status codes in use: `400` (malformed/missing input), `401`
(unauthenticated — see [`auth/backend.md`](auth/backend.md)), `404` (not
found), `422` (well-formed input that fails a domain rule), `500`
(internal error). `403` is reserved but not yet used anywhere.
