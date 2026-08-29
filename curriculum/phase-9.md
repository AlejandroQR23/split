# Phase 9: Authentication (Firebase Auth)

## Approach

After Phase 8, the app talks to a real backend but "you" are still just
whatever id `shared_preferences` happened to save on first launch — nothing
proves that identity belongs to the person holding the phone, and there's
no way to use the app as the same person on a second device. This phase
replaces that bootstrap identity with real accounts: sign-up, sign-in,
session persistence, and gating the app's screens behind "is someone
signed in," using Firebase Auth.

Firebase Auth was chosen over alternatives like Clerk for this project
specifically because its Flutter SDK (`firebase_auth`) is first-party and
mature, whereas Clerk's Flutter SDK is community-maintained and currently
beta. Firebase Auth doesn't require adopting any other Firebase product —
this phase uses it purely for identity.

**Scope note:** this phase is client-side only. Per
[`docs/frontend-guide.md`](../docs/frontend-guide.md), the API currently
trusts `X-User-Id` as-is and does not verify it — that's true before and
after this phase. See "Out of scope" below.

## Libraries / tools used this phase

- `firebase_auth` — [pub.dev](https://pub.dev/packages/firebase_auth)
- `firebase_core` — [pub.dev](https://pub.dev/packages/firebase_core)

## Required knowledge

Concepts from the graph in overview.md this phase assumes or introduces:

- **Riverpod providers** (assumed) — [docs](https://riverpod.dev/docs/concepts2/providers)
- **Riverpod consumers** (assumed) — [docs](https://riverpod.dev/docs/concepts2/consumers)
- **Declarative routing with go_router** (assumed) — [docs](https://pub.dev/packages/go_router)
- **Local key-value persistence** (assumed, as the mechanism being replaced) — [docs](https://pub.dev/packages/shared_preferences)
- **Third-party auth SDK integration** (introduced) — [docs](https://firebase.google.com/docs/auth/flutter/start)
- **Auth state as a Riverpod provider & route guarding** (introduced) — [docs](https://riverpod.dev/docs/concepts2/providers)

## Features

### 9.1 Pantallas de inicio de sesión y registro (suggested)

What it does: sign-up and sign-in screens built with the app's existing
shadcn_ui form patterns from Phase 4, backed by Firebase Auth (email/password
to start — social providers are a natural later extension, not required
here).
Concept(s) exercised: Third-party auth SDK integration — [docs](https://firebase.google.com/docs/auth/flutter/start).

No code. No step-by-step implementation instructions here — this is a
conceptual spec, not a recipe. The reader still has to work out the how.

Think about: Firebase Auth's calls are asynchronous and can fail in
user-facing ways (wrong password, email already in use, weak password) —
how do those map onto the form validation patterns from Phase 4, which so
far have only validated shape (is this field non-empty), not server-side
rejections? What should happen to a form's submit button while the auth
call is in flight?

### 9.2 Estado de sesión y rutas protegidas (suggested, evolving 3.1)

What it does: exposes Firebase Auth's current-user stream through a
Riverpod provider, and uses it to gate `go_router` navigation — signed-out
users are redirected to sign-in, and a successful sign-in returns them to
where they were headed.
Concept(s) exercised: Auth state as a Riverpod provider & route guarding — [docs](https://riverpod.dev/docs/concepts2/providers).

No code. No step-by-step implementation instructions here — this is a
conceptual spec, not a recipe. The reader still has to work out the how.

Think about: `go_router` re-evaluates redirects when a `Listenable` it's
told to watch changes — what does the auth provider need to expose for the
router to react to sign-in/sign-out automatically, rather than the app
manually pushing/popping routes on auth changes? What should the very
first frame show while Firebase is still resolving whether a session
already exists, before the app can know whether to show the signed-in or
signed-out flow?

### 9.3 De identidad de arranque a identidad real (suggested, evolving 8.3)

What it does: replaces Phase 8's `shared_preferences`-bootstrapped member id
with the signed-in Firebase user's identity. On first sign-in, the app
still needs a backend `Member` to send as `X-User-Id` — this feature wires
"a Firebase user just signed in for the first time" to "create (or look up)
the matching `Member`."
Concept(s) exercised: Third-party auth SDK integration, Auth state as a
Riverpod provider — [docs](https://firebase.google.com/docs/auth/flutter/start).

No code. No step-by-step implementation instructions here — this is a
conceptual spec, not a recipe. The reader still has to work out the how.

Think about: the backend has no concept of a Firebase uid — how does the
app decide "has this Firebase user already got a `Member`, or do I need to
create one" without a dedicated endpoint for that lookup? Is storing the
mapping (Firebase uid → `Member` id) still something `shared_preferences`
is right for, now that it's tied to a specific signed-in account rather
than "whoever has this device"?

## Out of scope (backend follow-up)

The API does not verify `X-User-Id` — it trusts the header as sent. This
phase makes the *client* honest (the id sent is now tied to a real signed-in
account), but nothing stops a modified client from sending someone else's
id. Making that safe requires backend changes outside this Flutter
curriculum: verifying Firebase ID tokens server-side (e.g. via the Firebase
Admin SDK in the Fastify layer) and deriving `X-User-Id`-equivalent identity
from the verified token rather than trusting a client-sent header. Flagging
this here so it isn't mistaken for "auth is fully solved" once this phase's
checklist is complete.

## Checklist

- [ ] 9.1 Pantallas de inicio de sesión y registro
- [ ] 9.2 Estado de sesión y rutas protegidas
- [ ] 9.3 De identidad de arranque a identidad real
