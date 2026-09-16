# Auth — backend contract

This documents how the client and the API establish identity today. It
**supersedes** the original Phase 8 design (an unverified, client-trusted
`X-User-Id: <memberId>` header) — if you see `X-User-Id` referenced
anywhere (older curriculum notes, code review history), it's describing
that earlier contract, not this one. The backend-verification follow-up
that Phase 9 originally flagged as future work has since happened.

## Authentication

Every request the app makes carries:

```
Authorization: Bearer <Firebase ID token>
```

sent by [`HttpClient`](../../lib/api/http_client.dart) for every request,
sourced from `AuthRepository.getIdToken()`. There is no more client-sent
identity header of any kind — the server is expected to derive the acting
identity from the verified token itself.

### Token refresh on 401

If a response is `401` with `error.code == "unauthenticated"`, the client:

1. Force-refreshes the Firebase ID token and retries the request once.
2. If the retry also comes back `401`, or the refresh itself throws, it
   signs the user out client-side and surfaces a `NetworkException` with
   code `unauthenticated` ("Session expired") to the caller.

This means a genuinely expired/invalid token is expected to produce
`401` + `{"error": {"code": "unauthenticated"}}` — any other 401 shape
won't trigger the refresh-and-retry path and will instead surface as a
generic error.

## Member provisioning: `GET /members/me`

A verified Firebase identity isn't automatically a backend `Member` — the
two are linked lazily. `GET /members/me` is a **get-or-create**: on the
first authenticated call for a given identity, it provisions a new
`Member` row (with `name` set to the placeholder `"New member"` — see
[`Member.placeholderName`](../../lib/models/member.dart)) and returns it;
every call after that returns the same `Member`.

Per the client's own doc comment on `currentMemberProvider`
(`lib/providers/current_member_provider.dart`), every *other* authenticated
route responds `401 member_not_linked` until `GET /members/me` has
resolved at least once for that identity — which is why the client always
resolves `currentMemberProvider` before letting any other repository call
run (see [`overview.md`](overview.md#member-provisioning) and
[`../architecture.md`](../architecture.md#providers)).

## Error codes introduced by this layer

| Code | Status | Meaning |
| --- | --- | --- |
| `unauthenticated` | 401 | Token missing, invalid, or expired. Triggers the client's refresh-and-retry (see above). |
| `member_not_linked` | 401 | Identity is verified but has no linked `Member` yet — call `GET /members/me` first. |

These are additive to the general error shape and status codes in
[`../architecture.md`](../architecture.md#error-shape).

## Scope — what's not covered

- **Authorization beyond "is this a valid token."** Nothing here describes
  per-resource permission checks (e.g. can this member act on this group)
  beyond what each domain doc's own error codes imply (e.g.
  `not_group_member` in [`../expenses/overview.md`](../expenses/overview.md)).
- **Social/third-party sign-in.** Only email/password is implemented
  client-side today.
- **Token storage/rotation details** on the backend — this doc only
  describes the contract observable from the Flutter client.
