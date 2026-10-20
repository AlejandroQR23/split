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
`{ "groups": [Group, ...] }`. The full collection, in no guaranteed order
— no `limit`, no pagination (see
[`../architecture.md`](../architecture.md#list-endpoints--pagination)).
For a bounded, activity-ordered slice of the same list, use
`GET /members/{memberId}/groups` below.

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

### `GET /members/{memberId}/groups`

Viewer-relative and bounded: this member's groups ordered by recent
activity, most recently active first — "recent activity" meaning the most
recent `date` among that group's expenses. Groups with no expenses at all
sort after every group that has one, in an unspecified order among
themselves.

Query params: `limit` (optional, integer, `1`-`100`, default `20`) — the
maximum number of groups to return.

`200` → `{ "groups": [Group, ...] }`. Each entry is the full `Group`
resource, the same shape `GET /groups` returns — just reordered and
capped.

Errors: `404 not_found` if the member doesn't exist;
`400 validation_error` if `limit` is outside `1`-`100`;
`400 user_mismatch` if `memberId` isn't the calling member — the shared
access rule for viewer-relative endpoints, see
[`../members/overview.md`](../members/overview.md#viewer-relative-endpoints).

Backs `recentGroupsProvider` (`lib/providers/groups_provider.dart`, which
asks for `limit: 3`) and the home screen's "Recent Groups" section, via
`GroupRepositoryImpl.fetchRecentGroups`.
