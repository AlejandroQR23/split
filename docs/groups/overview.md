# Groups

A `Group` is a name plus the set of members who split expenses together.
Group responses embed full `Member` objects (not bare ids), matching
[`lib/models/group.dart`](../../lib/models/group.dart) so a response maps
directly onto the Dart model.

## Resource

```json
{
  "id": "grp_01h...",
  "name": "Cabin trip",
  "members": [
    { "id": "mem_01h...", "name": "Alex Rivera" },
    { "id": "mem_02h...", "name": "Sam Lee" }
  ]
}
```

Repository: [`lib/repositories/group_repository.dart`](../../lib/repositories/group_repository.dart).
Provider: `groupRepositoryProvider` (`lib/providers/groups_provider.dart`) —
`null` while there's no signed-in member, per
[`../architecture.md`](../architecture.md#providers).

## Endpoints

### `POST /groups`

Create a group. The creator (the authenticated member — see
[`../auth/backend.md`](../auth/backend.md)) doesn't need to be listed in
`memberIds` explicitly; the server adds them automatically if absent, so
every group always includes its creator.

Request: `{ "name": "string", "memberIds"?: ["string", ...] }` → `201` the
full `Group`.

Errors: `422 validation_error` if `name` is empty; `404 not_found` if any
id in `memberIds` doesn't exist (with `details.memberIds` listing the bad
ones).

### `GET /groups`

Lists groups the calling member belongs to. `200` →
`{ "groups": [Group, ...] }`.

### `GET /groups/{groupId}`

`200` → the `Group`. `404 not_found`.

### `PATCH /groups/{groupId}`

Only `name` is patchable here — membership changes go through the
dedicated endpoints below so each change is one auditable operation rather
than a diff of an array.

Request: `{ "name"?: "string" }` → `200` the updated `Group`.

Errors: `404 not_found`; `422 validation_error`.

### `DELETE /groups/{groupId}`

Deletes the group **and its expenses** (see
[`../expenses/overview.md`](../expenses/overview.md)). `204`.
`404 not_found`.

### `POST /groups/{groupId}/members`

Add an existing member to the group. Request:
`{ "memberId": "string" }` → `200` the updated `Group`.

Errors: `404 not_found` (group or member); `422 already_member` if
they're already in the group.

### `DELETE /groups/{groupId}/members/{memberId}`

Remove a member from the group. `204`.

Errors: `404 not_found` (group, or member not in group); `422
has_open_balance` if that member has a nonzero balance in this group per
the current settlement calculation
([`../balances/overview.md`](../balances/overview.md)) — removing them
would silently erase a debt. There is no force-remove; the client should
surface this rather than allow silent data loss.

## Known discrepancy

`GroupRepositoryImpl.fetchRecentGroups` (used for the home screen's
"Recent Groups" section) calls `GET members/{userId}/groups?limit=N`, an
endpoint not described above — the only documented groups-list route is
`GET /groups`, with no path-embedded member id or `limit` param. This is a
tracked, unresolved finding — see [`../../todo.md`](../../todo.md) — not a
documented part of the contract; don't treat it as spec.
