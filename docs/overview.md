# Split — Overview

Split is a group-expense-splitting app (think Splitwise): groups of people
log what they paid and who it's split between, and the app nets out
balances and reduces them to the minimum number of transfers needed to
settle up.

It doubles as a **Flutter + Riverpod learning project** — see
[`curriculum/`](../curriculum/overview.md) for the phased learning plan this
app is built against. That's a different concern from this `docs/` tree:
`curriculum/` describes the order concepts were introduced and why;
`docs/` describes what the app actually does and how it's actually built,
regardless of which phase introduced it. When in doubt about current
behavior, trust `docs/` and the code over `curriculum/`.

## Start here

- [`architecture.md`](architecture.md) — tech stack, app layering
  (models/repositories/providers/screens), routing, error-handling
  conventions, and the backend API conventions shared by every domain below.
- [`design-system.md`](design-system.md) — visual identity: colors,
  typography, spacing, components. Required reading before touching any UI
  (see the root [`CLAUDE.md`](../CLAUDE.md)).

## Features

| Feature | Docs | What it covers |
| --- | --- | --- |
| Auth & identity | [`auth/overview.md`](auth/overview.md), [`auth/backend.md`](auth/backend.md) | Firebase sign-up/sign-in, session state, route guarding, linking a signed-in account to a backend `Member` |
| Members | [`members/overview.md`](members/overview.md) | The `Member` resource — the person behind an expense or a group |
| Groups | [`groups/overview.md`](groups/overview.md) | The `Group` resource — who's splitting expenses together |
| Expenses | [`expenses/overview.md`](expenses/overview.md), [`expenses/payments.md`](expenses/payments.md), [`expenses/labels.md`](expenses/labels.md) | Logging shared expenses, recording settle-up payments, and tagging expenses with a reusable per-group label |
| Balances & settling up | [`balances/overview.md`](balances/overview.md) | Computing who owes whom, and the minimum set of transfers to settle a group |
| Notifications | [`notifications/overview.md`](notifications/overview.md) | Push for new expenses/payments and the monthly debt reminder, device-token registration, and per-member preferences |
| Observability | [`observability/overview.md`](observability/overview.md) | Error reporting (Sentry) and product analytics (PostHog): identify/reset on sign-in/out, the event catalog, and what gets reported as an error vs. shown to the user |

## Other references

- [`known-bugs/`](known-bugs/) — postmortems for non-obvious bugs, kept for
  the reasoning even after the bug is fixed (each is marked with its
  status).
- [`../todo.md`](../todo.md) — open findings from code review, not yet
  actioned.
