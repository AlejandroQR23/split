# Payments (settle-up)

A payment records that one member **paid another back**, outside of the
usual "log what was bought and split it" flow. This is how a computed
balance ([`../balances/overview.md`](../balances/overview.md)) actually
gets reduced — see that page for the read side; this page covers the write.

A payment is represented as an [`Expense`](overview.md) with
`type: "payment"`: `paidBy` is who paid, and `shares` has exactly one
entry — who was paid back. It's not a separate resource because it already
has almost the same shape (someone paid, someone else was owed) and needs
to flow through the same balance math as a regular expense, without a
second code path.

Model: `CreatePaymentInput` in
[`lib/models/expense.dart`](../../lib/models/expense.dart). Repository
method: `ExpenseRepository.addPayment`.

## `POST /groups/{groupId}/payments`

Request:

```json
{
  "fromMemberId": "mem_01h...",
  "toMemberId": "mem_02h...",
  "amount": 20.00,
  "date": "2026-09-06T10:00:00Z"
}
```

`date` is optional, defaulting to "now" (UTC). Any positive `amount` is
accepted — partial payments and overpayments are both valid; the server
doesn't cap the amount at the counterparties' current computed balance
(there's no stored balance to cap it against — balances are always
recomputed, see [`../balances/overview.md`](../balances/overview.md)).

`201` → a full `Expense` with `type: "payment"`, `concept: "Settle up"`
(server-set, ignoring any client input), and exactly one share —
`{ member: toMember, amount }`.

Errors (all `422 validation_error` unless noted): `amount` ≤ 0;
`fromMemberId === toMemberId`; `422 not_group_member` if either id exists
but isn't a member of this group; `404 not_found` if either id doesn't
exist as a member at all.

## Correcting a payment

There is no `PATCH` for a payment
([`422 payment_not_editable`](overview.md#patch-expensesexpenseid)) — the
only way to correct one is `DELETE /expenses/{expenseId}`, which undoes it
and lets the balance recompute as if it never happened.

## In the UI

The pending-settlements list (see
[`../balances/overview.md`](../balances/overview.md)) is what makes this
actionable: tapping a transfer you're a party to opens `settle_up_screen`
prefilled with the suggested amount — editable, so partial payments work.
Because a payment is an `Expense` under the hood, it also shows up in the
existing expense-history feeds ([`overview.md`](overview.md)) alongside
regular expenses, distinguished by `type`/`Expense.isPayment` so it isn't
mistaken for spending in a "N expenses" count.
