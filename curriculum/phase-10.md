# Phase 10: Settling up

## Approach

Every phase through 9 treats a balance as something you only ever *look
at*: `GET /groups/{groupId}/transfers` computes the minimum set of payments
that would settle a group, but nothing in the app or the API lets anyone
act on that number — there's no persisted fact that would make a computed
transfer shrink or disappear. This phase closes that loop: recording that
one member paid another back, so the balance screen's numbers actually
move instead of only ever being read.

The key design decision this phase makes concrete: a settle-up is **new
data, not a flag on a computed result**. `Transfer` (Phase 8.4) has no id
and no row behind it — it's recomputed fresh from expenses on every
request, so there is nothing to mark `settled: true` on. Instead, settling
up is recorded the same way an expense is: as a fact that feeds the *next*
computation, the way Splitwise's "record a payment" works. Concretely, a
payment is persisted as an `Expense` with a `type` discriminator
(`"expense"` vs `"payment"`) rather than as a separate resource, since it
already has almost the same shape (someone paid, someone else was paid
back) and needs to flow through the same balance math without a second
code path.

## Libraries / tools used this phase

None new — this phase is entirely new endpoints and screens built on
Phase 8's `http` integration and Phase 4's form/component patterns.

## Required knowledge

Concepts from the graph in overview.md this phase assumes or introduces:

- **HTTP client & REST integration** (assumed) — [docs](https://pub.dev/packages/http)
- **Repository pattern** (assumed) — [docs](https://dart.dev/language/classes)
- **Wiring a repository through a Riverpod provider** (assumed) — [docs](https://riverpod.dev/docs/concepts2/providers)
- **Forms & validation** (assumed) — [docs](https://docs.flutter.dev/cookbook/forms/validation)
- **Declarative routing with go_router** (assumed) — [docs](https://pub.dev/packages/go_router)
- **Modeling a discriminated union across a network boundary** (introduced) — [docs](https://dart.dev/language/branches)

## Features

### 10.1 Registrar pagos y saldar deudas (suggested, evolving 5.1, 6.1, 8.4)

What it does: lets a member record that they paid — or were paid by —
another member of a group, via `POST /groups/{groupId}/payments`
([`docs/expenses/payments.md`](../docs/expenses/payments.md)).
The pending-settlements list (Phase 6) becomes actionable: tapping a
transfer you're a party to opens a form prefilled with the suggested
amount — editable, so partial payments work — and submitting it reduces
(or, on an overpayment, reverses) that balance the next time it's
recomputed. Because a payment is an `Expense` under the hood, it also
shows up in the existing expense-history feeds and can be undone the same
way an expense is deleted.
Concept(s) exercised: HTTP client & REST integration, Modeling a
discriminated union across a network boundary — [docs](https://pub.dev/packages/http).

No code. No step-by-step implementation instructions here — this is a
conceptual spec, not a recipe. The reader still has to work out the how.

Think about: the backend accepts a payment between any two members of a
group, no matter who's asking — should the UI let you record a payment
between two *other* people, or only ones you're a party to? A `Transfer`
has no id to "select" — what identifies which debt a settle-up form is
for, if not the transfer itself? Now that `GET .../expenses` returns
payments merged in with regular expenses, what in the existing history UI
(and its "N expenses" count) needs to branch on `type` so a payment
doesn't get mistaken for spending?

## Checklist

- [x] 10.1 Registrar pagos y saldar deudas
