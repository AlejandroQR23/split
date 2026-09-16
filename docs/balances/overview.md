# Balances & settling up

Nothing about a balance is stored — every endpoint on this page recomputes
its answer from a group's current expenses (which, per
[`../expenses/payments.md`](../expenses/payments.md), includes payments)
on every call. A payment nets against the debt exactly like any expense,
so recording one via `POST /groups/{groupId}/payments` is what actually
moves these numbers.

The debt-simplification math itself no longer lives in this client. An
earlier phase (5) had a local, unit-tested `compute_settlements.dart` as
the reference implementation; Phase 8.4 replaced every call site with the
server endpoints below once balances became genuinely multi-user data, and
the local algorithm was removed once nothing called it. If you need its
logic for reference, it's in git history, not in `lib/`.

There are three read shapes, each answering a different question:

| Endpoint | Scope | Answers |
| --- | --- | --- |
| `GET /groups/{groupId}/transfers` | Group, not viewer-relative | "What's the minimum set of payments to settle *this group*, regardless of who's asking?" |
| `GET /groups/{groupId}/settlements` | Group, viewer-relative | "What does *the calling member* owe/get owed within *this group*?" |
| `GET /members/{memberId}/settlements` | Cross-group, viewer-relative | "What does *the calling member* owe/get owed in total, across every group?" |

## `GET /groups/{groupId}/transfers`

Ports a balance-then-greedy-match algorithm: the minimum set of payments
that would settle every balance in the group.

```json
{ "transfers": [ { "from": "mem_02h...", "to": "mem_01h...", "amount": 42.25 } ] }
```

`from`/`to` are bare member ids, not embedded objects — the one asymmetric
shape in this API, matching
[`lib/models/transfer.dart`](../../lib/models/transfer.dart) exactly,
where `Transfer.from`/`Transfer.to` are `String` by design (transfers are
meant to be trivially comparable/hashable — see its `==`/`hashCode`
override). Don't "fix" this into embedded objects.

An empty `transfers` array means the group is already settled. Errors:
`404 not_found` if the group doesn't exist.

Repository: [`lib/repositories/transfer_repository.dart`](../../lib/repositories/transfer_repository.dart).
Provider: `groupTransfersProvider` (family, keyed by `groupId`).

## `GET /groups/{groupId}/settlements`

Viewer-relative but scoped to one group: the calling member's net balance
against each counterparty **within this group only**. Same `Settlement`
shape as the cross-group endpoint below. Backs
`groupSettlementsProvider` / `GroupSettlementsNotifier`
(`lib/providers/settlement_provider.dart`), used by the group-details
screen's balance summary.

## `GET /members/{memberId}/settlements`

Viewer-relative and **cross-group**: this member's net balance against
every counterparty they share any expense with, across all of that
member's groups combined. Powers the home screen's "you owe / you're
owed" summary (`allSettlementsProvider`).

```json
{
  "settlements": [
    {
      "counterparty": { "id": "mem_02h...", "name": "Sam Lee" },
      "netAmount": 42.25,
      "summary": "Groceries"
    }
  ]
}
```

`netAmount` positive means the counterparty owes `memberId`; negative
means `memberId` owes the counterparty. `summary` describes what the debt
is *for*, not how it's being paid off — it's the expense concept if
there's exactly one contributing expense, `"N expenses"` if there are
several, or `"Settle up"` if the remaining balance is driven only by
payments (e.g. an overpayment). Counterparties who net to exactly zero are
omitted, sorted by `netAmount.abs()` descending.

Model: [`lib/models/settlement.dart`](../../lib/models/settlement.dart).
Repository: [`lib/repositories/settlement_repository.dart`](../../lib/repositories/settlement_repository.dart).

Only the calling member may fetch their own settlements — there's no path
to view another member's.

## In the UI

`pending_settlement.dart` / `transfer_card.dart`
(`lib/widgets/settlement/`) render the transfer list as actionable cards;
tapping one you're a party to opens the settle-up form described in
[`../expenses/payments.md`](../expenses/payments.md).
