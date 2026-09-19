# Labels

A `Label` is a named, colored, optionally-iconed category scoped to one
group and reusable across that group's expenses — "Food", "Rent",
"Transport". An expense carries at most one, picked (or created inline)
from the add-expense form; there's no editing a label onto/off an existing
expense yet, and no rename/delete for a label itself.

Model: [`lib/models/label.dart`](../../lib/models/label.dart).
Repository: [`lib/repositories/label_repository.dart`](../../lib/repositories/label_repository.dart).
Provider: [`lib/providers/labels_provider.dart`](../../lib/providers/labels_provider.dart)
— `groupLabelsProvider(groupId)`, mirroring `expensesProvider`'s
family-by-group shape.

## Resource

```json
{
  "id": "lbl_01h...",
  "groupId": "grp_01h...",
  "name": "Food",
  "color": "#4CB963",
  "icon": "🍕"
}
```

`color` is parsed with `colorFromHex` ([`lib/utils/formatting.dart`](../../lib/utils/formatting.dart)),
which degrades to `AppColors.primary` on a malformed value rather than
throwing — one bad label shouldn't crash the whole expense list, the same
tolerance `ExpenseType.fromJson` applies to an unknown `type`.

## Endpoints

### `POST /groups/{groupId}/labels`

Request: `{ "name": "Food", "color": "#4CB963", "icon": "🍕" }` (`icon`
optional). `201` → the full `Label`.

Errors (all `422 validation_error` unless noted): `name` blank; `color`
not a 6-digit hex code; `name` already used in this group,
case-insensitively (`422 label_name_taken`).

### `GET /groups/{groupId}/labels`

`200` → `{ "labels": [Label, ...] }`, alphabetical by `name`. `404
not_found` for an unknown group.

## UI

The add-expense form ([`lib/widgets/expenses/label_field.dart`](../../lib/widgets/expenses/label_field.dart))
shows a chip row ([`lib/widgets/expenses/label_selector.dart`](../../lib/widgets/expenses/label_selector.dart))
of the selected group's labels, single-select, tapping the selected chip
clears it (a label is optional). A trailing "+ New" chip opens
[`lib/widgets/expenses/create_label_sheet.dart`](../../lib/widgets/expenses/create_label_sheet.dart)
to create one inline — name, a color swatch from `AppColors.labelPalette`,
and an emoji picker — which the form then selects automatically. The
selected label is cleared whenever the group picker changes, since a
label from one group isn't valid for another.

The label renders as a chip on every expense row via the shared
[`ExpenseTileContent`](../../lib/widgets/history/expense_tile_content.dart),
covering group history, the home "Recent activity" feed, and the guest
invite view in one place. Settle-up payments never show one.

See [`overview.md`](overview.md#post-groupsgroupidexpenses) for how
`labelId` attaches to an expense at creation.
