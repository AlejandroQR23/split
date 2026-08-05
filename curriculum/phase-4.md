# Phase 4: UI components, forms & media

## Approach

This phase is where the app stops being read-only. Adding an expense means
building the app's most complex form: several interacting fields (who paid,
who it's split between), validation, and an optional photo attachment
sourced from the device. It's also the natural point to bring in shadcn_ui
in earnest — its form components are what this screen is built from, rather
than raw Material widgets.

## Libraries / tools used this phase

- `shadcn_ui` — [docs](https://flutter-shadcn-ui.mariuti.com)
- `image_picker` — [docs](https://pub.dev/packages/image_picker)

## Required knowledge

Concepts from the graph in overview.md this phase assumes or introduces:

- **Layout widgets** (assumed) — [docs](https://docs.flutter.dev/ui/layout)
- **shadcn_ui components & theming** (introduced) — [docs](https://flutter-shadcn-ui.mariuti.com)
- **Forms & validation** (introduced) — [docs](https://docs.flutter.dev/cookbook/forms/validation)
- **`image_picker` & async platform APIs** (introduced) — [docs](https://pub.dev/packages/image_picker)

## Features

### 4.1 Formulario para añadir gasto (your idea)

What it does: a form for logging a new expense — title, amount, who paid,
who it's split between, and an optional photo of the receipt captured via
`image_picker`. Built with shadcn_ui form components, with validation on the
required fields, and on submit it writes the new expense through the
repository from Phase 2 so it shows up in that group's detail screen from
Phase 3.
Concept(s) exercised: shadcn_ui components & theming, Forms & validation,
`image_picker` & async platform APIs — [docs](https://flutter-shadcn-ui.mariuti.com).

No code. No step-by-step implementation instructions here — this is a
conceptual spec, not a recipe. The reader still has to work out the how.

Think about: which shadcn_ui components fit "pick one payer from the group's
members" versus "pick several people to split between" — are these the same
kind of input? What has to be true of the form before "submit" should even
be enabled, and how does validation communicate that back to the user?
`image_picker`'s calls are asynchronous and can be cancelled by the user
(no photo chosen) — how does the form's state need to account for "no photo
yet," "user is picking," and "photo chosen" as distinct outcomes?

## Checklist

- [ ] 4.1 Formulario para añadir gasto
