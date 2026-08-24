# Fitness Application Design System

## Purpose

This document is the design contract for the Fitness Application. Every Flutter
screen must use these semantic tokens through the app theme rather than placing
hex colors, font names, or arbitrary text styles directly in widgets.

The source is the Figma `Fonts_and_Colors` board, node `1:2` in the Fitness App
community file. The Flutter implementation will live under `App/lib/theme/`.

## Foundations

### Typography

The product font family is `Lato`. The Figma source supplies these weights:

| Token | Lato weight | Flutter `FontWeight` | Usage |
| --- | --- | --- | --- |
| `font-regular` | Regular | `w400` | Body copy, helper text |
| `font-medium` | Medium | `w500` | Emphasized body, labels |
| `font-semibold` | SemiBold | `w600` | Buttons, tabs, section labels |
| `font-bold` | Bold | `w700` | Titles, key metrics |
| `font-extrabold` | ExtraBold | `w800` | Display headings, hero metrics |

The first Flutter theme pass uses Material 3 text roles with the above weights.
Font sizes and line heights will be refined from individual Figma screens when
those screens are implemented; no page may create a second font family.

### Color Tokens

The palette below is taken directly from the Figma source. Semantic names define
how code uses a color; they do not alter the source values.

| Token | Hex | Semantic role |
| --- | --- | --- |
| `color-background` | `#192126` | Primary app background |
| `color-accent` | `#BBF246` | Primary action, selected state, progress highlight |
| `color-neutral-500` | `#8B8F92` | Secondary text, inactive icon |
| `color-neutral-600` | `#5E6468` | Tertiary text, disabled content |
| `color-neutral-800` | `#384046` | Surface border, elevated dark surface |
| `color-violet` | `#A48AED` | Workout or chart series A |
| `color-danger` | `#ED4747` | Destructive action, error state, alert metric |
| `color-warning` | `#FCC46F` | Warning state, chart series B |
| `color-info` | `#95CCE3` | Informational state, chart series C |

### Derived Semantic Roles

`ThemeData` maps the foundation tokens to Material 3 roles as follows:

| Material role | Token |
| --- | --- |
| `ColorScheme.surface` / `scaffoldBackgroundColor` | `color-background` |
| `ColorScheme.primary` | `color-accent` |
| `ColorScheme.onPrimary` | `color-background` |
| `ColorScheme.secondary` | `color-violet` |
| `ColorScheme.error` | `color-danger` |
| `ColorScheme.onSurface` | white for readable foreground text |
| `ColorScheme.onSurfaceVariant` | `color-neutral-500` |
| `ColorScheme.outline` | `color-neutral-800` |

White foreground text is an implementation semantic required for contrast on the
dark primary background. It is not a new branded palette color.

## Component Rules

### Buttons

- Primary button: `color-accent` fill, `color-background` label, Lato SemiBold.
- Destructive button: `color-danger` fill or outline depending on the screen's
  destructive-action hierarchy.
- Disabled buttons use a muted neutral treatment; never reuse the accent color
  at full opacity.

### Text

- Display and screen titles use Lato ExtraBold or Bold.
- Section headings use Lato Bold or SemiBold.
- Buttons and navigation labels use Lato SemiBold.
- Body copy uses Lato Regular; key values can use Medium or Bold.
- Secondary and inactive copy use `color-neutral-500` or `color-neutral-600`.

### Surfaces And States

- App canvas uses `color-background`.
- Elevated dark elements and dividers use `color-neutral-800`.
- Do not use `color-violet`, `color-warning`, or `color-info` as generic CTA
  colors. They are reserved for chart series, workout categories, and semantic
  states.
- Error content must use `color-danger`; warning content must use
  `color-warning`.

### Charts And Fitness Metrics

- Default series order: violet, warning, info, then accent.
- Never convey a metric state by color alone; pair it with a label, icon, or
  value change.
- Keep `color-danger` reserved for negative or alerting meaning, never normal
  progress.

## UX Philosophy — Gamified Social

> Source: product decision for HealthStride, 2026-08-10. Not from Figma.

HealthStride is a hybrid of the **Social & Community** and **Emotional & Hedonic** presets. The
product exists to make employees *want* to exercise, so the interface must reward action
immediately and make progress visible to peers.

| Knob | Setting | Consequence for design |
| --- | --- | --- |
| Content density | Low-medium | One primary action per screen. Cards, not tables. |
| Device target | Mobile-first | Bottom tab bar, thumb-reachable primary actions. |
| Animation budget | Moderate-high | Points, level-up and badge moments are animated. Navigation is not. |
| Confirmation style | Inline + undo | `AlertDialog` only for irreversible actions (redeem points, delete a log). |
| Gamification | Heavy | Points, levels, badges, streaks and rank are first-class UI, not footnotes. |
| Identity depth | High | Avatar, level and rank appear wherever a person is named. |
| Empty states | Inviting | "Log your first workout to earn 100 points", never a bare "No data". |

### Non-negotiable rules

1. **Every point-earning action gets visible feedback within 300 ms.** Logging a workout must
   animate the point gain — the reward loop is the product.
2. **Logging a workout is never more than two taps from any screen.** A persistent action button
   sits in the bottom navigation.
3. **Lifetime points and available points are always labelled distinctly.** Never render a bare
   number that could be read as either (see `business-understanding.md` §6.8).
4. **Progress is shown, not stated.** Prefer a ring, bar or sparkline over a sentence.
5. **Tap targets are at least 48×48 dp.** Users interact mid-workout with sweaty hands.

### Anti-patterns

- Dense data tables (reserve tabular layout for the admin screens only)
- Multi-step wizards for logging a workout
- Confirmation dialogs on non-destructive actions
- Conveying rank, streak or achievement state by color alone
- Sidebar or drawer navigation as the primary nav

## Spacing Scale

> Source: product decision, 8 dp base grid. Not from Figma. Revise when Figma layout frames arrive.

| Token | Value | Usage |
| --- | --- | --- |
| `space-2xs` | 4 dp | Icon-to-label gap, chip inner padding |
| `space-xs` | 8 dp | Related elements inside one card |
| `space-sm` | 12 dp | Card inner padding on compact cards |
| `space-md` | 16 dp | Default card padding, screen horizontal margin |
| `space-lg` | 24 dp | Between distinct sections of a screen |
| `space-xl` | 32 dp | Above a screen's primary call to action |
| `space-2xl` | 48 dp | Hero metric breathing room, empty-state padding |

Screen horizontal margin is `space-md` (16 dp) on all screens. Do not vary it per screen.

## Radius And Elevation

> Source: product decision. Not from Figma.

| Token | Value | Usage |
| --- | --- | --- |
| `radius-sm` | 8 dp | Chips, badges, small inputs |
| `radius-md` | 12 dp | Buttons, text fields, list rows |
| `radius-lg` | 16 dp | Cards, sheets |
| `radius-xl` | 24 dp | Hero cards, modal sheets |
| `radius-full` | 999 dp | Avatars, progress rings, pill buttons |

The app is dark-canvas, so **elevation is expressed by surface color, not by shadow**.

| Level | Surface | Usage |
| --- | --- | --- |
| Level 0 | `color-background` | App canvas |
| Level 1 | `color-neutral-800` at 40% over canvas | Cards, list rows |
| Level 2 | `color-neutral-800` | Bottom sheets, dialogs, selected states |
| Level 3 | `color-neutral-800` + 1 dp `color-neutral-600` border | Modal dialogs only |

Drop shadows are permitted only on the floating action button and on bottom sheets, at low
opacity. Never use shadow to separate two cards on the same surface — use `space-sm` instead.

## Layout Pattern

Mobile-first, single-column. The app uses a **bottom tab bar** with five destinations and a
centered floating action for logging a workout.

```
┌──────────────────────────────┐
│  App bar (contextual)        │  56 dp — title + optional action
├──────────────────────────────┤
│                              │
│  Scrollable content          │  16 dp horizontal margin
│  (cards, feed, lists)        │
│                              │
├──────────────────────────────┤
│  Home  Feed  [+]  Rank  Me   │  Bottom navigation, 64 dp + safe area
└──────────────────────────────┘
```

| Destination | Screen | Icon intent |
| --- | --- | --- |
| Home | `SCR-HOME-10` Dashboard | Overview of points, level, streak, goal |
| Feed | `SCR-SC-20` Activity Feed | Company activity |
| **Log** | `SCR-WO-11` Log workout | Center floating action, `color-accent` fill |
| Rank | `SCR-SC-10` Leaderboard | Standings |
| Me | `SCR-PROF-10` Profile | Identity, history, settings |

The reward store `SCR-RW-10` is reached from the Home dashboard and from the Profile screen; it
does not occupy a tab slot because it is a lower-frequency destination than the five above.

Admin screens (`SCR-ADM-*`) use a conventional list-and-detail layout without the bottom tab bar,
since they serve a different role and a different task rhythm.

## Motion

> Source: product decision. Not from Figma.

| Token | Duration | Curve | Usage |
| --- | --- | --- | --- |
| `motion-instant` | 100 ms | `Curves.easeOut` | Button press, chip selection |
| `motion-quick` | 200 ms | `Curves.easeInOut` | Sheet open, tab switch, list item enter |
| `motion-reward` | 600 ms | `Curves.easeOutBack` | Point gain counter, progress ring fill |
| `motion-celebrate` | 1200 ms | `Curves.elasticOut` | Level-up and badge-earned overlays |

Reward and celebrate motions are the only places where playful easing is permitted. Navigation
must stay calm — a user opening the app forty times a month will find bouncy navigation tiring.

Respect the platform reduced-motion setting: when it is on, replace `motion-reward` and
`motion-celebrate` with a cross-fade at `motion-quick` and keep the numeric result identical.

## Component Rules — Extended

### Cards

Cards are the primary content container. Default card: `color-neutral-800` at 40% over canvas,
`radius-lg`, `space-md` padding. Cards never carry a border unless they represent a selected
state, in which case the border is 1 dp `color-accent`.

### Bottom navigation

Five items, `color-accent` for the active item, `color-neutral-500` for inactive. Active state
must pair the accent color with a filled icon variant — color alone is not a permitted state
indicator. The center Log action is a 56 dp circle, `color-accent` fill, `color-background` icon.

### Inputs

`radius-md`, `color-neutral-800` fill, no outline at rest. Focus state shows a 1 dp
`color-accent` border. Error state shows a 1 dp `color-danger` border plus a `color-danger`
helper line below — never color alone.

### Bottom sheets

Logging flows (workout, water, weight) open as bottom sheets rather than full screens, so the
user keeps context. `radius-xl` on the top corners only, drag handle in `color-neutral-600`,
Level 2 surface.

### Empty states

Every empty state carries three parts: an illustrative icon in `color-neutral-600`, a sentence
explaining what will appear here, and a primary action that fills it. Never render a bare
"No data".

## Gamification Components

These are HealthStride-specific compositions. They are design contracts, not Material widgets.

### Points display

Two distinct treatments so the numbers are never confused:

| Value | Treatment | Where |
| --- | --- | --- |
| Lifetime points | Lato ExtraBold, `color-accent`, with a small "total" label | Dashboard hero, leaderboard rows |
| Available points | Lato Bold, white, with a wallet icon and "available" label | Reward store header, redemption sheet |

Anywhere both appear together, they must be visually adjacent and both labelled.

### Level ring

A circular progress ring showing progress toward the next level. Track `color-neutral-800`,
fill `color-accent`, `radius-full`. The center holds the level number in Lato ExtraBold. Below
the ring, a line reads "X of Y points to Level N+1" — the ring alone never carries the meaning.

### Badge tile

Square tile, `radius-lg`. Earned badges use full-color artwork on a Level 1 surface. Unearned
badges use the same artwork at 30% opacity on the canvas, with the unlock condition rendered
beneath in `color-neutral-500`. Unearned badges are never hidden — seeing the goal is the point.

### Streak indicator

A flame icon plus a day count. Color escalates with the streak length to give the number
emotional weight, but the count is always rendered as text beside it:

| Streak | Icon color |
| --- | --- |
| 1–6 days | `color-neutral-500` |
| 7–13 days | `color-warning` |
| 14–29 days | `color-accent` |
| 30+ days | `color-danger` used as a "hot" accent, paired with a filled flame |

This is the single sanctioned exception to the rule reserving `color-danger` for negative
meaning. It is permitted only on the streak indicator at 30+ days, and only when the flame icon
is filled so the state reads as intensity rather than error.

### Leaderboard row

Rank number, avatar, name, lifetime points, and a streak indicator. The current user's own row
uses a Level 2 surface with a 1 dp `color-accent` left edge so it is findable while scrolling.
Ranks 1–3 carry a medal glyph in `color-warning`, `color-neutral-500` and a bronze tint
respectively, always alongside the numeric rank.

### Point-gain toast

After a workout is saved, a toast animates the earned amount from zero using `motion-reward`.
When the daily or per-session cap has been applied, the toast must additionally state the reason
in plain language, for example "300 points awarded — the per-session maximum".

## Accessibility

- Text contrast against `color-background` must meet WCAG AA. `color-neutral-600` is
  approved for decorative and disabled content only, never for content the user must read.
- Never convey state by color alone. Every rule above that assigns a color also assigns an icon,
  label or numeric value.
- Minimum tap target 48×48 dp, including icon buttons in the app bar.
- All progress rings and charts expose a text alternative through `Semantics`.
- Honor the platform reduced-motion setting as described in the Motion section.

## Flutter Contract

The Flutter theme implementation is organised into these modules:

| File | Responsibility | Status |
| --- | --- | --- |
| `lib/theme/app_colors.dart` | Immutable foundation and semantic color constants | Implemented |
| `lib/theme/app_typography.dart` | Lato-based Material 3 text theme | Implemented |
| `lib/theme/app_theme.dart` | Dark Material 3 `ThemeData` and component-theme defaults | Implemented |
| `lib/theme/app_spacing.dart` | Spacing, radius and elevation-surface constants | To build |
| `lib/theme/app_motion.dart` | Duration and curve constants | To build |

Widget code must obtain common colors and typography from
`Theme.of(context).colorScheme` and `Theme.of(context).textTheme`. It may refer
to `AppColors` only for named chart series or domain-specific fitness metrics
which are not represented by a Material color role.

Gamification components live under `lib/widgets/gamification/` and must consume the tokens
above rather than redefining values.

Widget code must obtain common colors and typography from
`Theme.of(context).colorScheme` and `Theme.of(context).textTheme`. It may refer
to `AppColors` only for named chart series or domain-specific fitness metrics
which are not represented by a Material color role.

## Asset Requirement

Before the Flutter theme is enabled, the project must include the Lato font
files for Regular, Medium, SemiBold, Bold, and ExtraBold under
`App/assets/fonts/` and declare them in `App/pubspec.yaml`. Do not rely on a
runtime network font download.

## Validation

- Compare each implemented Figma screen against this document before review.
- Run `flutter analyze` and `flutter test` after theme integration.
- Test on both Android and iOS simulators.
- Check text contrast on the dark background and verify that color is not the
  sole indicator of a state.

## Scope

This system covers two layers, and the distinction matters when Figma frames arrive.

**Layer 1 — from Figma** (`Fonts_and_Colors`, node `1:2`): font family, font weights, and the
color palette. These values are authoritative; do not change them without a new Figma source.

**Layer 2 — from product decisions** (2026-08-10): UX philosophy, spacing scale, radius,
elevation, layout pattern, motion, extended component rules, and the gamification components.
These were derived from the HealthStride business documents in `Document/HealthStride/` because
no Figma layout frames exist yet. When Figma supplies layout frames, reconcile them against this
layer and record any change here rather than in widget code.

Icons are not yet specified. The app currently depends only on `cupertino_icons`; an icon set
decision is still open.

## Related Documents

| Document | Relationship |
| --- | --- |
| `Document/HealthStride/screen-flow.md` | Source of the screen inventory this layout pattern serves |
| `Document/HealthStride/business-understanding.md` | Business rules behind the gamification components |
| `Document/HealthStride/decision-log.md` | Why lifetime and available points are rendered separately (D-003) |
| `Document/HealthStride/screens/` | Per-screen design and behaviour specifications |
