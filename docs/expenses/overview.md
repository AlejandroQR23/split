# Expenses

An `Expense` belongs to exactly one group: someone (`paidBy`) paid an
`amount` for `concept`, split across one or more `shares`. `paidBy` and
each share's `member` are embedded `Member` objects, matching
[`lib/models/expense.dart`](../../lib/models/expense.dart).

Deleting a group ([`../groups/overview.md`](../groups/overview.md))
deletes all of its expenses too — there's no standalone "delete all
expenses in a group" endpoint, since that's exactly what
`DELETE /groups/{groupId}` already does.

An `Expense` can also represent a settle-up **payment** — see
[`payments.md`](payments.md) — distinguished by `type`.

## Resource

```json
{
  "id": "exp_01h...",
  "groupId": "grp_01h...",
  "concept": "Groceries",
  "amount": 84.50,
  "paidBy": { "id": "mem_01h...", "name": "Alex Rivera" },
  "shares": [
    { "member": { "id": "mem_01h...", "name": "Alex Rivera" }, "amount": 42.25 },
    { "member": { "id": "mem_02h...", "name": "Sam Lee" }, "amount": 42.25 }
  ],
  "date": "2026-08-22T14:30:00Z",
  "type": "expense"
}
```

`type` is `"expense"` or `"payment"` (see [`payments.md`](payments.md)).
`ExpenseType.fromJson` degrades any unknown/absent value to `expense`
rather than throwing, so the client tolerates a future server-side type it
doesn't know about yet.

Repository: [`lib/repositories/expense_repository.dart`](../../lib/repositories/expense_repository.dart).

## Endpoints

### `POST /groups/{groupId}/expenses`

Request:

```json
{
  "concept": "Groceries",
  "amount": 84.50,
  "paidById": "mem_01h...",
  "shares": [
    { "memberId": "mem_01h...", "amount": 42.25 },
    { "memberId": "mem_02h...", "amount": 42.25 }
  ],
  "date": "2026-08-22T14:30:00Z"
}
```

`date` is optional; defaults to "now" (UTC) if omitted. `201` → the full
`Expense`.

Errors (all `422 validation_error` unless noted): `amount` ≤ 0; `shares`
empty; `shares[].amount` values don't sum to `amount` (0.005 epsilon
tolerated for float rounding); `paidById` or a `shares[].memberId` isn't a
member of `groupId` (`404 not_found` if the id doesn't exist as a member
at all, vs. `422 not_group_member` if it exists but isn't in this group).

### `GET /groups/{groupId}/expenses`

`200` → `{ "expenses": [Expense, ...] }`, most recent `date` first. Merges
expenses and payments into one feed by default — pass `?type=expense` or
`?type=payment` to narrow to one kind.

### `GET /expenses/{expenseId}`

`200` → the `Expense`. `404 not_found`.

### `PATCH /expenses/{expenseId}`

Same body shape as `POST`, all fields optional — only provided fields
change. If you send `shares` without `amount`, the new shares must still
sum to the *existing* amount, and vice versa.

`200` → the updated `Expense`.

Errors: same as `POST`, plus `404 not_found`, plus `422
payment_not_editable` if the target is a payment — payments can't be
edited, only undone (see [`payments.md`](payments.md)).

### `DELETE /expenses/{expenseId}`

`204`. `404 not_found`. Works unchanged on a payment — deleting one is how
a settle-up gets undone.

## Known discrepancy

`ExpenseRepositoryImpl.fetchExpenses` (the cross-group feed behind the
home screen's "Recent Activity") calls `GET members/{userId}/expenses`, an
endpoint not described above — the documented feeds are
`GET /groups/{groupId}/expenses` (this page) and
`GET /members/{memberId}/settlements`
([`../balances/overview.md`](../balances/overview.md)). This is a tracked,
unresolved finding — see [`../../todo.md`](../../todo.md) — not spec.
