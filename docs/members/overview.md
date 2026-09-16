# Members

A `Member` is a person: `{ id, name }`. Every group and every expense
ultimately references one or more members. See
[`../auth/overview.md`](../auth/overview.md) for how a signed-in Firebase
identity gets linked to a `Member` in the first place — this page covers
the `Member` resource itself.

## Resource

```json
{ "id": "mem_01h...", "name": "Alex Rivera" }
```

Model: [`lib/models/member.dart`](../../lib/models/member.dart).
Repository: [`lib/repositories/member_repository.dart`](../../lib/repositories/member_repository.dart).

A freshly-provisioned member (see `GET /members/me` in
[`../auth/backend.md`](../auth/backend.md)) has
`name == Member.placeholderName` ("New member") until the person sets a
real one via `SetNameScreen`.

## Endpoints

### `POST /members`

Create a member directly (used when adding someone to a group who isn't a
registered user yet — see [`../groups/overview.md`](../groups/overview.md)).

Request: `{ "name": "string" }` → `201` the created `Member`.

Errors: `422 validation_error` — `name` missing, empty, or whitespace-only.

### `GET /members/me`

Get-or-create for the calling authenticated identity. See
[`../auth/backend.md`](../auth/backend.md#member-provisioning-get-membersme)
— this is the one member endpoint that's about identity, not about
looking up an arbitrary member.

### `GET /members/{memberId}`

`200` → the `Member`. `404 not_found` if no member with that id exists.

### `GET /members?ids=id1,id2,id3`

Bulk fetch, used to hydrate a list of members by id (e.g. a group's member
list) in one round trip. `200` →
`{ "members": [Member, ...] }`. Unknown ids are silently omitted from the
result rather than erroring — a caller diffing the returned list against
the ids it asked for can tell which ones no longer exist.

### `PATCH /members/{memberId}`

Partial update. Request: `{ "name"?: "string" }`. `200` → the updated
`Member`.

Errors: `404 not_found`; `422 validation_error` if `name` is present but
empty/whitespace-only.

There is no `DELETE /members/{memberId}` — deleting a person who has
expense history attached is a data-integrity question (what happens to
their `paidBy`/`shares` references?) that's intentionally out of scope for
now.
