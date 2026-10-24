# Observability

Error reporting is Sentry; product analytics is PostHog. Both were
considered against the Firebase-native alternative (Crashlytics +
Analytics) and picked instead because the app already treats Firebase as
identity-only (see [`auth/overview.md`](../auth/overview.md)) — pulling in
Crashlytics/Analytics would mean a second Firebase product surface for no
benefit, where Sentry and PostHog are both drop-in SDKs with no other
coupling to the rest of the stack.

## `.env` keys

| Key | Purpose | If unset |
| --- | --- | --- |
| `SENTRY_DSN` | Sentry project DSN | `SentryFlutter.init` still runs with `options.dsn = null` — the SDK no-ops and nothing is sent |
| `POSTHOG_API_KEY` | PostHog project key | `PostHogAnalyticsService.init` returns immediately without calling `Posthog().setup` — every later `identify`/`reset`/`capture` call is a no-op (guarded by an `_initialized` flag) |
| `POSTHOG_HOST` | Self-hosted/regional PostHog instance URL | Falls back to PostHog's default host; only applied when non-empty |

All three are optional and blank-safe — a fresh `.env` with empty values
runs the app with observability fully disabled, no code changes needed.

## The two abstractions

Both are behind a hand-rolled interface rather than called directly, so a
screen or provider never imports `sentry_flutter`/`posthog_flutter` itself:

- [`ErrorReportingService`](../../lib/services/error_reporting_service.dart)
  — `setUser(String? userId)`, `captureException(Object error, StackTrace stackTrace)`.
  `SentryErrorReportingService` is the only implementation, exposed via
  `errorReportingServiceProvider`
  ([`lib/providers/error_reporting_provider.dart`](../../lib/providers/error_reporting_provider.dart)).
- [`AnalyticsService`](../../lib/services/analytics_service.dart) —
  `init()`, `identify(String userId)`, `reset()`, `capture(String event, {Map<String, Object?>? properties})`.
  `PostHogAnalyticsService` is the only implementation, exposed via
  `analyticsServiceProvider`
  ([`lib/providers/analytics_provider.dart`](../../lib/providers/analytics_provider.dart)).
  `capture`'s `properties` map drops any `null` value before handing it to
  `Posthog().capture` — PostHog's property map isn't nullable.

Both providers are plain (non-`autoDispose`) `Provider`s, so callers just
`ref.read` them; nothing about reporting an error or an event depends on
which member, if any, is currently signed in.

`main()` calls `analyticsServiceProvider.init()` once, before `runApp`, and
wraps the whole app in `SentryFlutter.init(..., appRunner: () => runApp(...))`
(`lib/main.dart`) — Sentry's own init owns the `runApp` call so it can catch
anything that throws during startup.

## Identify / reset lifecycle

[`lib/utils/session_telemetry.dart`](../../lib/utils/session_telemetry.dart)
has two pure functions, both wired into `main()`'s `container.listen` calls:

- `identifyTelemetryUser({errorReporting, analytics, memberId})` — calls
  `errorReporting.setUser(memberId)` and `analytics.identify(memberId)`.
  Triggered by a `container.listen(currentMemberProvider, ...)` callback,
  the moment `currentMemberProvider` resolves to a non-null `Member`.
- `resetTelemetryOnSignOut({errorReporting, analytics})` — calls
  `errorReporting.setUser(null)` and `analytics.reset()`. Triggered by a
  `container.listen(authStateProvider, ...)` callback, the moment
  `authStateProvider` resolves to a null `User`.

The two listen on **different** providers, not the same one twice, and
that's deliberate: identify needs the backend `Member` id
(`currentMemberProvider`, which only resolves once `GET /members/me` has
provisioned or fetched a row — see
[`auth/overview.md#member-provisioning`](../auth/overview.md#member-provisioning)),
while reset only needs "Firebase says nobody's signed in"
(`authStateProvider`) — waiting on `currentMemberProvider` to go null first
would be waiting on a provider that may never resolve again once its
dependency (the signed-in `User`) is already gone. Tagging happens as late
as possible (after provisioning); untagging happens as early as possible
(right at sign-out).

## What gets reported to Sentry from the HTTP client

`ApiHttpClient._checkStatusCode`
([`lib/api/api_http_client.dart`](../../lib/api/api_http_client.dart))
calls `captureException` in exactly two cases:

- A **mapped** status code (`400`, `401`, `404`, `422`, `500`) whose
  numeric value is `>= 500`. In practice that's just `500` — the only
  mapped 5xx.
- Any status code **not** in that mapped list at all (the fallback
  branch), regardless of whether it's a 4xx or 5xx — an API returning,
  say, a `418` is as unexpected as a `503`.

A mapped 4xx (`400`, `401`, `404`, `422`) throws its `NetworkException` for
the caller to handle (field errors, a "not found" screen, a `ShadToast`,
...) but never reports to Sentry — those are expected, user-facing
outcomes (a validation error, an expired token), not bugs. Only server-side
failures and genuinely unanticipated responses are error-reporting
material.

## Event catalog

Captured via `analyticsServiceProvider.capture(event, properties: {...})`,
each exactly once on the success path of its mutation — never on failure,
since a failed mutation already surfaces via a thrown `NetworkException`
and a `ShadToast`.

| Event | Properties | Fired from |
| --- | --- | --- |
| `sign_in` | none | `AuthScreen._handleSubmit` after `signIn` succeeds ([`lib/screens/auth/auth_screen.dart`](../../lib/screens/auth/auth_screen.dart)) |
| `sign_up` | none | `AuthScreen._handleSubmit` after `signUp` succeeds (same file) |
| `group_created` | `{memberCount: int}` | `GroupsNotifier.addGroup` ([`lib/providers/groups_provider.dart`](../../lib/providers/groups_provider.dart)) |
| `expense_created` | `{amount: double, splitCount: int}` | `ExpensesNotifier.addEvenExpense` ([`lib/providers/expenses_provider.dart`](../../lib/providers/expenses_provider.dart)) |
| `settle_up_recorded` | `{amount: double}` | `ExpensesNotifier.settleUp` (same file) |

This table is the place a future event gets added to — add the row here
alongside the `capture` call, not just the call site, since this is the
only list of what the app actually tracks.

## Non-goals

Session replay, performance tracing/transactions, feature flags (PostHog
supports both but neither is wired up), breadcrumb customization beyond
Sentry's defaults, and reporting client-side validation failures (form
errors never reach `ErrorReportingService` — only HTTP-layer exceptions
do).
