# Push notifications

Two pushes exist today: a **new-expense/payment** notification to everyone
involved when someone else logs one, and a **monthly debt reminder** to
anyone with a negative net balance. Both are individually switchable from
Profile → Preferencias
([`lib/screens/profile/preferences_screen.dart`](../../lib/screens/profile/preferences_screen.dart)).

Firebase Cloud Messaging sends both; the backend composes every title and
body server-side (never on-device), because a `notification` payload is
what the OS renders when the app is killed.

## Device registration

A `Device` is one app install's FCM registration token plus its platform.
Registered via `DeviceRepository`
([`lib/repositories/device_repository.dart`](../../lib/repositories/device_repository.dart))
and keyed by a **server-generated id**, not by the token itself — the
token never appears in a URL path or a response body (it's a credential;
anyone holding it can push to that device), and
[`FirebaseMessaging.onTokenRefresh`](https://pub.dev/packages/firebase_messaging)
yields only the *new* token, so a token-keyed resource would orphan a row
on every rotation.

| Method | Path | Purpose |
| --- | --- | --- |
| `POST` | `/devices` | Register/refresh. Idempotent on the FCM token — the same token re-registering under a different member reassigns the row rather than duplicating it. `201` on insert, `200` on refresh. |
| `PATCH` | `/devices/{deviceId}` | Rotate the token (`onTokenRefresh`) or change platform. `404` (never `403`) if the device belongs to someone else — a 403 would confirm the id exists at all. |
| `DELETE` | `/devices/{deviceId}` | Unregister. `204`. |
| `GET` | `/devices` | List the caller's own devices. |

**Lifecycle on the client** (`lib/providers/push_provider.dart`):

- On first resolve of `currentMemberProvider` with no device id stored
  locally (`shared_preferences`, key `push_device_id` —  this app's first
  real use of that dependency), request OS permission, then register and
  persist the id the server returns.
- On `onTokenRefresh`, `PATCH` the stored device with the new token.
- **Before** signing out of Firebase — not after — `DELETE` the stored
  device, then clear the local id. Order matters: the delete needs a live
  Firebase ID token, so sign out would invalidate it first and orphan the
  row. The delete is best-effort; a failure never blocks sign-out.
- Registration failures are caught and logged, never left unhandled — seen
  in practice, `getToken()` can throw `FCM Registration failed!` on a
  freshly-booted Android emulator before Play Services has warmed up. No
  device id gets stored on a failure, so the next app launch just retries.

All device/preference routes require an actual Firebase-linked account
(`requireAccount`) — ghost members have no Firebase identity and so no
device to register.

## Preferences

Separate from `Device`, one row per member:

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/members/me/notification-preferences` | → `{ notifyNewExpense, notifyMonthlyReminder }`. Defaults to `true`/`true` when no row exists yet — never backfilled. |
| `PATCH` | `/members/me/notification-preferences` | Partial update → the full result. |

Backed by `NotificationPreferences`
([`lib/models/notification_preferences.dart`](../../lib/models/notification_preferences.dart))
and `notificationPreferencesProvider`
([`lib/providers/notification_preferences_provider.dart`](../../lib/providers/notification_preferences_provider.dart)),
which follows the same optimistic-mutate-and-revert-on-error shape as
`ExpensesNotifier._mutateAndRefresh`.

## Data payload — how a tap routes

Every push carries a `data` map the app uses to navigate, rather than raw
ids — the routing rule lives on the server, and a future notification type
needs no client release:

```
type  = "new_expense" | "new_payment" | "monthly_reminder"
route = "/groups/group/<uuid>"   (new_expense, new_payment)
      | "/"                      (monthly_reminder)
```

`extractNotificationRoute` (`lib/utils/push_notifications.dart`) validates
`type` against an allowlist and `route` against the two permitted shapes
before ever calling `go()` — a malformed or future-versioned payload is
ignored, never routed blind.

**Signed-out taps.** `resolveAuthRedirect` bounces any route to `/sign-in`
while signed out, and go_router has no memory of the original destination
once sign-in resolves. A tap that arrives signed-out is stashed in
`pendingNotificationRouteProvider` and delivered exactly once the moment
`currentMemberProvider` resolves (wired in `main()`) — the same pattern
`pendingInviteTokenProvider` uses for invite links.

## New expense / payment

Recipients: every non-ghost member in the expense's `shares`, plus the
payer, minus whoever created it. Ghost ≡ no linked Firebase account.

Copy (composed server-side, Spanish): `"{payer} pagó {amount} por
{concepto}"` for an expense; distinct second-person copy for a payment
(`"{payer} te pagó {amount}"` / `"{creator} registró tu pago de
{amount}"`) — a payment's internal placeholder concept
(`"Quedamos a manu"`) must never reach a lock screen.

**Expenses generated by the recurring-expense machinery do not notify.**
That generation runs on the `GET /groups/{groupId}/expenses` read path
(whoever happens to open the group), so there's no meaningful actor to
exclude, the timing is non-deterministic (possibly weeks late, possibly
several backfilled occurrences at once), and nothing records whether a
push was already sent for a given occurrence. The trigger lives on the
interactive `POST` handlers only — which also means a **user-created**
recurring expense's first occurrence still notifies, since that one is
created synchronously inside the `POST`.

Dispatch is fire-and-forget: it runs after the response is sent and can
never fail or slow down expense/payment creation, even if the FCM
credential is misconfigured or a send throws.

## Monthly reminder

Fires **the 1st of each month at a fixed UTC hour (10:00
`America/Mexico_City`)**, to every member with a negative net balance
across all their groups and the preference enabled. Deep-links to `/`
(home), where the balance screen lives.

There is no per-member timezone — `members` has no timezone column and
this feature deliberately doesn't add one. Mexico abolished DST in 2022,
so the fixed UTC offset never drifts off 10:00 locally; members in other
timezones get the local equivalent, which may be an odd hour. Revisit only
if that becomes a real complaint, not preemptively.

## Non-goals

Notifications for edited/deleted expenses, group invites, or settle-up
events; per-device preference overrides (preferences are per-member);
badge counts or an in-app notification inbox; a durable retry queue —
delivery is best-effort.
