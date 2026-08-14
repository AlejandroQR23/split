# Split — Design System

This is the single source of truth for the app's visual identity. If you're
a human or a coding agent about to build UI in this app, read this first.

**Stack:** Flutter + [`shadcn_ui`](https://pub.dev/packages/shadcn_ui)
`^0.56.1`.
**Theme:** light only — there is no dark mode.
**Font:** Plus Jakarta Sans (via `google_fonts`).

## The vibe

Clean, flat, confident. Generous whitespace, generously rounded corners —
fully pill-shaped buttons, large-radius cards — one accent color used
sparingly (primary buttons, active states, positive amounts). Body copy is
near-black, not pure black. No gradients, no heavy shadows, no visual noise.

## Golden rule

**Never hardcode a color, font size, spacing value, radius, or shadow in a
widget.** Every visual value in the app comes from one of the token files
below. If a value you need doesn't exist yet, add it to the token file — do
not inline it. This is what keeps the whole app re-themeable from four
files.

## File map

```
lib/theme/
  app_colors.dart      # color tokens + the ShadColorScheme
  app_typography.dart  # Plus Jakarta Sans text theme + signature type styles
  app_spacing.dart     # spacing scale, radii, shadows
  app_theme.dart        # assembles the above into AppTheme.light (ShadThemeData)
lib/widgets/
  floating_nav_bar.dart # the app's bottom navigation chrome
lib/main.dart            # ShadApp wiring: theme: AppTheme.light
```

`app_theme.dart` is the **only** file that should construct `ShadThemeData`.
Everything else reads tokens from `AppColors`, `AppTypography`,
`AppSpacing`/`AppRadii`/`AppShadows`.

---

## Colors

Defined in `lib/theme/app_colors.dart` as `AppColors`. Two brand anchors —
everything else is a derived tint of one of them, so the palette shares one
undertone.

| Token                   | Hex       | Role                                                                                        |
| ----------------------- | --------- | ------------------------------------------------------------------------------------------- |
| `primary`               | `#4CB963` | **Brand anchor.** Emerald — primary buttons, active nav state, positive amounts, focus ring |
| `primaryForeground`     | `#FFFFFF` | Text/icons on top of `primary`                                                              |
| `primaryDark`           | `#3F9A52` | Pressed/hover state for primary surfaces                                                    |
| `primaryTint`           | `#E8F6EC` | Light emerald surface — active nav pill background, badges, selection highlight             |
| `ink`                   | `#0C1618` | **Brand anchor.** Near-black — all body text, headings                                      |
| `background`            | `#FFFFFF` | App background, card background                                                             |
| `surface`               | `#F5F6F6` | Muted fill — secondary button background                                                    |
| `mutedForeground`       | `#6D7577` | Secondary/caption text, inactive nav icons                                                  |
| `border`                | `#E5E8E8` | Borders, dividers, input outlines                                                           |
| `destructive`           | `#E5484D` | Errors, destructive actions                                                                 |
| `destructiveForeground` | `#FFFFFF` | Text/icons on top of `destructive`                                                          |

These feed `AppColors.lightScheme`, a `ShadColorScheme` wired into
`ShadTheme.of(context).colorScheme`, so any shadcn component (`ShadButton`,
`ShadCard`, `ShadInput`, etc.) already uses the right colors without extra
work.

**To re-theme the whole app**, change `primary` and/or `ink` in
`app_colors.dart` — everything derived from them (tints, the color scheme,
button/card themes) follows automatically.

**Usage:**

```dart
final theme = ShadTheme.of(context);
theme.colorScheme.primary          // don't do AppColors.primary in ad-hoc widgets
                                     // if a shadcn component already exposes the color
Container(color: AppColors.surface) // fine for custom (non-shadcn) widgets
```

---

## Typography

Defined in `lib/theme/app_typography.dart` as `AppTypography`. Base font is
**Plus Jakarta Sans**, applied across shadcn's entire type scale via
`ShadTextTheme.fromGoogleFont`.

### shadcn scale — use these for anything resembling standard content

Access via `ShadTheme.of(context).textTheme.<name>`:

| Style                             | Use for                                                                                |
| --------------------------------- | -------------------------------------------------------------------------------------- |
| `h1Large`, `h1`, `h2`, `h3`, `h4` | Section/page headings (rarely needed — prefer `screenTitle` for top-level page titles) |
| `p`                               | Body copy                                                                              |
| `lead`                            | Intro/standfirst paragraphs                                                            |
| `large`                           | Emphasized inline text                                                                 |
| `small`                           | Fine print                                                                             |
| `muted`                           | Secondary/caption text — pre-colored `mutedForeground`, no need to override color      |
| `blockquote`, `table`, `list`     | As named                                                                               |

Default text color is ambient `ink` (applied by the theme, not baked into
each style) — you don't need to set color explicitly for normal text.
`muted` is the one style with its color pre-set to `mutedForeground`.

### Signature tokens — the app's identity moments

Access via `AppTypography.<name>` (static, not through `ShadTheme`):

| Token           | Size / weight     | Use for                        |
| --------------- | ----------------- | ------------------------------ |
| `amountDisplay` | 34px / w700 / ink | Big balance/amount numbers     |
| `screenTitle`   | 24px / w700 / ink | Page headers (e.g. "Overview") |
| `navLabel`      | 11px / w600       | Bottom nav item captions       |

**Usage:**

```dart
Text('Overview', style: AppTypography.screenTitle);
Text('\$1,240.00', style: AppTypography.amountDisplay);
Text('Your balance', style: ShadTheme.of(context).textTheme.muted);
```

---

## Spacing, radii, shadows

Defined in `lib/theme/app_spacing.dart`.

### `AppSpacing` — 4pt base scale

| Token  | Value |
| ------ | ----- |
| `xs`   | 4     |
| `sm`   | 8     |
| `md`   | 12    |
| `lg`   | 16    |
| `xl`   | 24    |
| `xxl`  | 32    |
| `xxxl` | 48    |

Use for all `EdgeInsets`, `SizedBox` gaps, etc. — don't write raw numbers.

### `AppRadii` — corner radius scale

| Token  | Value | Use for                                                                                       |
| ------ | ----- | ---------------------------------------------------------------------------------------------- |
| `sm`   | 12    | Small elements (chips, small badges)                                                          |
| `md`   | 16    | **App-wide default** — inputs and most non-button/card components (`ShadThemeData.radius`)    |
| `lg`   | 24    | Cards, sheets (`ShadCardTheme.radius`)                                                        |
| `xl`   | 32    | Large hero surfaces (e.g. a big balance card)                                                 |
| `pill` | 999   | Fully-rounded shapes — floating nav bar, active nav pill, **and every `ShadButton` variant**  |

Buttons are wired to `pill` explicitly (not `md`) in `app_theme.dart` — every
`ShadButton` variant (primary, secondary, destructive, outline, ghost) is
fully stadium-shaped, per the brand reference. Cards are wired to `lg`
explicitly via `cardTheme.radius`; without that override they'd fall back to
the global `md` radius like inputs do.

### `AppShadows` — ink-tinted, not pure black

| Token  | Use for                                                                         |
| ------ | ------------------------------------------------------------------------------- |
| `card` | Subtle lift for cards/surfaces resting on the background (4% ink, blur 12, y+4) |
| `nav`  | Elevated float for the bottom nav bar (10% ink, blur 24, y+8)                   |

---

## Theme assembly

`lib/theme/app_theme.dart` exports `AppTheme.light`, a `ShadThemeData` that
wires colors + typography + radius + component sub-themes
(`primaryButtonTheme`, `secondaryButtonTheme`, `cardTheme`) together. It's
consumed once, in `lib/main.dart`:

```dart
ShadApp(
  theme: AppTheme.light,
  themeMode: ThemeMode.light,
  home: const HomeShowcasePage(),
)
```

Don't construct a second `ShadThemeData` anywhere else in the app — extend
`app_theme.dart` instead if a new component needs a themed default.

---

## Components

### Buttons — use shadcn's `ShadButton` variants directly

```dart
ShadButton(onPressed: () {}, child: const Text('Add expense'));           // primary — emerald
ShadButton.secondary(onPressed: () {}, child: const Text('Settle up'));   // neutral surface
ShadButton.destructive(onPressed: () {}, child: const Text('Delete'));    // red
ShadButton.outline(...) / ShadButton.ghost(...) / ShadButton.link(...)    // as needed
```

Colors/radius come from `AppTheme.light` automatically — every variant is
fully pill-shaped (`AppRadii.pill`). Don't pass `backgroundColor` etc. per
call unless a one-off truly needs it.

### Cards — `ShadCard`

```dart
ShadCard(
  title: Text('Trip to Lisbon', style: theme.textTheme.h4),
  description: const Text('4 members · 12 expenses'),
  child: ...,
);
```

Already themed with `AppColors.background` + `AppShadows.card` +
`AppRadii.lg` corners.

### Icons — Lucide, via shadcn_ui's export

```dart
import 'package:shadcn_ui/shadcn_ui.dart'; // exports LucideIcons

Icon(LucideIcons.plus)
```

Use Lucide icons everywhere for visual consistency — avoid Material icons.

### Floating bottom nav — `FloatingNavBar`

Custom widget (shadcn has no bottom-nav component), in
`lib/widgets/floating_nav_bar.dart`. A white floating pill, tokens only, no
hardcoded styling.

```dart
FloatingNavBar(
  items: const [
    FloatingNavItem(icon: LucideIcons.house, label: 'Home'),
    FloatingNavItem(icon: LucideIcons.activity, label: 'Activity'),
    FloatingNavItem(icon: LucideIcons.users, label: 'Groups'),
    FloatingNavItem(icon: LucideIcons.user, label: 'Profile'),
  ],
  currentIndex: _navIndex,
  onTap: (i) => setState(() => _navIndex = i),
)
```

Behavior: active item shows its icon + label in `primary` on a
`primaryTint` rounded pill; inactive items show icon only, in
`mutedForeground`. Place it in a `Stack`/`Positioned` over the page body
(see `lib/main.dart`), and give scrollable content enough bottom padding
(`AppSpacing.xxxl * 2` works well) so it doesn't sit under the bar.

---

## Adding new UI: checklist

1. Reach for an existing `shadcn_ui` component first (`ShadInput`,
   `ShadSelect`, `ShadDialog`, `ShadBadge`, etc.) — it already inherits
   `AppTheme.light`.
2. Need custom layout? Use `AppColors` / `AppTypography` / `AppSpacing` /
   `AppRadii` / `AppShadows` tokens — never a raw `Color(0x...)`, font size,
   or `EdgeInsets` number.
3. Need a genuinely new token (a new color, a new text style)? Add it to the
   relevant `lib/theme/*.dart` file with a one-line doc comment explaining
   its role, not inline in the widget.
4. If it's app-wide chrome (like the nav bar), it belongs in `lib/widgets/`
   as its own token-driven widget, not copy-pasted per screen.
