# PingDesignSystem — Reference & AI Guide

This is the complete reference for the PingDesignSystem Swift package: every token, modifier, and component, every decision behind them, and a step-by-step operating manual for building or updating sample apps with it.

- **Code:** [`Sources/PingDesignSystem/`](Sources/PingDesignSystem/) — the single source of truth for all values in this document (`PingTheme.swift` holds every token; the catalog preview lives in `Catalog/`).
- **Governance:** [`DESIGN_SYSTEM.md`](DESIGN_SYSTEM.md) — purpose, component contracts, and governance. This README is the full reference; DESIGN_SYSTEM.md is the policy.

**If you are an AI agent asked to create or update a sample app that consumes this package (PingExample or the sdk-sample-apps samples):** read §1 (the operating manual) and §2 (the golden rules) first, then use §4–§7 as your API reference, and run the §8 checklist before you finish. Everything you need is copy-pasteable from §5.1.

---

## Table of contents

1. [Operating manual for AI agents](#1-ai-operating-manual)
2. [Golden rules](#2-golden-rules)
3. [Architecture: the four styling tiers](#3-the-four-styling-tiers)
4. [Token reference](#4-token-reference)
5. [Modifiers reference](#5-modifiers-reference)
6. [Components reference](#6-components-reference)
7. [Buttons: roles and states](#7-buttons-buttons-and-states)
8. [Decision records](#8-decision-records)
9. [Documented exceptions](#9-documented-exceptions)
10. [Extending the system](#10-extending-the-system)

---

## 1. AI operating manual

You are creating or updating a SwiftUI sample app that consumes this package (PingExample, or a sample in the `sdk-sample-apps` repo). Follow this procedure.

### 1.1 Start from the recipe, not from SwiftUI

Build every screen from the recipe below. It routes typography, color, spacing, and control styling through the design system — nothing here is hand-typed.

```swift
import SwiftUI

struct RegistrationView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var errorMessages: [String] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PingTheme.Spacing.medium) {
                Text("Create Account")                          // screen title
                    .pingScreenTitle()

                // — text field —
                VStack(alignment: .leading, spacing: PingTheme.Spacing.small) {
                    Text("Username")                            // field label
                        .pingSectionHeader()

                    TextField("Username", text: $username)
                        .pingTextFieldStyle(showsError: !errorMessages.isEmpty)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)

                    PingFieldMessages(errorMessages: errorMessages)
                }

                // — password field (secure entry + visibility toggle + validation) —
                PingSecureField(
                    label: "Password",
                    text: $password,
                    isVisible: $showPassword,
                    errorMessages: errorMessages
                )

                // — primary call to action —
                Button("Continue") { submit() }
                    .buttonStyle(.pingPrimary)
            }
            .padding(PingTheme.Spacing.screen)
            .pingReadableContentWidth()
        }
        .pingScreenBackground()
    }
}
```

### 1.2 Choose styling by decision, not appearance

Every styling choice maps to a semantic intent. Never pick by color; pick by meaning:

| The thing you want | The system's answer |
|---|---|
| Full-screen grouped background | `.pingScreenBackground()` |
| Card around a group of content | `.pingCardStyle()` (`.large` for hero emphasis) |
| Editable text entry | `.pingTextFieldStyle(showsError:)` |
| Label above a field / section heading | `.pingSectionHeader()` |
| Screen/card/step title | `.pingScreenTitle()` |
| De-emphasized supporting copy | `.pingSupportingText()` |
| Compact de-emphasized metadata | `.pingCaptionText()` |
| Notification/status message body | `.pingBodySecondary()` |
| Field validation messages | `PingFieldMessages(errorMessages:)` |
| Password field | `PingSecureField` |
| Dominant flow action | `.buttonStyle(.pingPrimary)` |
| Lower-emphasis / recovery action | `.buttonStyle(.pingSecondary)` |
| Destructive action (delete, deny, log out) | `.buttonStyle(.pingDestructive)` |
| Approve / authenticate / positive confirm | `.buttonStyle(.pingAffirmative)` |
| Apple / Google / Facebook sign-in | `.buttonStyle(PingActionButtonStyle(role: .provider(background:foreground:)))` |
| Icon in a branded tile or avatar | `PingIconTile(systemName:)` (optional `isLocked:` badge) |
| Determinate circular progress | `PingProgressRing(progress:)` |
| Read-only label/value row | `PingInfoRow(label:value:)` |
| Loading state (over content, blocking) | `PingLoadingOverlay()` in a conditional `ZStack` |
| Loading state (inline, non-blocking) | `PingLoadingSpinner()` |
| Empty-state composition | `EmptyStateView(icon:title:subtitle:actions:)` |
| Centered empty state | `PingCenteredScrollContent { … }` (owns its `ScrollView`; branch at the same level, never nest inside one) |
| Error alert bound to a view model | `.pingErrorAlert(errorMessage:)` |
| Screen-scroll content padding | `.pingScrollContentPadding()` |
| Status banner (error/success) | `.pingStatusCardStyle(tint:)` |
| MFA number selection | `PingChallengeNumberButton(number:action:)` |
| Numbered instructional step | `PingStepBadge(number:)` |
| Status readout (approved/expired/pending/denied) | `statusSuccess` / `statusWarning` / `statusInfo` / `statusError` |
| iPad width cap | `.pingReadableContentWidth()` |

### 1.3 Status-color decision table

| State | Token | Examples in this app |
|---|---|---|
| Success / positive outcome | `PingTheme.Color.statusSuccess` | Approved, Connected, "Completed", copy-success |
| Warning / needs attention | `PingTheme.Color.statusWarning` | Expired, "Found" (migration needed), not registered |
| Error / destructive | `PingTheme.Color.statusError` | Failed, Access Denied, validation errors |
| In progress / informational | `PingTheme.Color.statusInfo` | "Migrating…", "Pending" — status **text** only |
| Loading indicator tint | `PingTheme.Color.actionPrimary` | **Never** a status color — see D7 |

### 1.4 Composition rules for a new screen

- Screen root: `ScrollView` → `.pingScreenBackground()` (or the tint on the screen's `ZStack` — one owner, never both).
- Content: `VStack(alignment: .leading)` with `PingTheme.Spacing` gaps, wrapped in `.padding(PingTheme.Spacing.screen)` and `.pingReadableContentWidth()`.
- Buttons: real `Button`s with a role style — never hand-rolled `Text` + `.background` + `.cornerRadius`.
- Field behavior (keyboard type, capitalization, autocorrection, submission) is configured at the call site, next to the field. The styling modifier intentionally does not set it.
- Accessibility: icon-only controls get explicit `.accessibilityLabel`; tap targets stay ≥ 44pt.

### 1.5 Before you finish — checklist

Run each of these; every one must pass.

- [ ] No raw SwiftUI colors: no `.foregroundColor(.red|.gray|.white...)`, no `Color.systemX`, no bare `.primary`/`.secondary` — use `PingTheme.Color.*`.
- [ ] No raw text fonts: no `Font.system(size:)` for text — use `PingTheme.Typography.*` (image sizing is fine).
- [ ] No spacing/radius magic numbers that match a token value (4/8/16/20; radii 8/10/12/16/20) — use the token.
- [ ] No card triplets hand-rolled (`background` + `clipShape` + `shadow`) — use `.pingCardStyle(size:)`.
- [ ] No hand-rolled primary/secondary/destructive fills — use the button role styles.
- [ ] No disabled-state gray ternaries — use `.disabled(condition)`; the button style paints disabled state.
- [ ] Dark mode: every color you applied pairs correctly with the surface behind it. If you paired a color with a foreground yourself, check it works in dark appearance — or better, don't pair them yourself: use a modifier/component that owns the pairing.
- [ ] Every consuming app builds (PingExample, and the sdk-sample-apps samples) with `import PingDesignSystem` resolving — no `No such module` and no raw-style regressions.

---

## 2. Golden rules

These are the invariants behind everything above. Violating any of them re-opens the bug classes this system exists to close.

1. **Semantic roles, never raw values.** Every color, font, spacing, radius, and control dimension comes from `PingTheme`. Raw values make meaning unsearchable and drift inevitable.
2. **Use the lowest tier that expresses the situation.** Direct tokens for one-off styling; a parameterized modifier when a combination recurs; a component when 3+ flows converge on identical composition *and* behavior is centralized (§3).
3. **Never pair an action color with a foreground yourself.** `actionPrimary` goes with `actionPrimaryForeground`, and both are dynamic — pairing either with a literal `.white` breaks dark mode. The modifiers/components own these pairings; callers can't get them wrong (§9, D3).
4. **Don't layer a modifier's internals.** `.pingCardStyle()` owns padding, surface, radius, and shadow. Adding your own `.padding()` outside it double-pads (see the "Styles and modifiers" contract table in DESIGN_SYSTEM.md).
5. **Style is visual-only.** Modifiers never configure keyboard, capitalization, autocorrection, content type, or submission — each field opts into those at the call site based on its meaning (D5).
6. **No generic layer owns SDK behavior.** Components never accept Journey callbacks, DaVinci collectors, view models, navigation state, or Ping SDK types. SDK-aware views compose these styles but own their own flow.
7. **Provider branding stays caller-decided.** Apple/Google/Facebook keep their documented branding requirements; the system shares only shape/pressed/disabled mechanics via `.provider(background:foreground:)`.
8. **Status colors describe state; spinners aren't status.** `statusInfo` is for in-progress *text*. A spinner tint is `actionPrimary` — tinting one red made "waiting" look like an error (§9, D7).

---

## 3. The four styling tiers

Everything in SwiftUI is a modifier, but styling lives on four tiers. Reach for the lowest one that fully expresses the situation:

```swift
// Tier 0 — raw SwiftUI values. FORBIDDEN outside documented exceptions.
.foregroundColor(.red)                              // semantic meaning unknown

// Tier 1 — direct PingTheme tokens (vocabulary)
.foregroundStyle(PingTheme.Color.statusError)

// Tier 2 — custom modifier: several attributes + one decision, under one name
.pingTextFieldStyle(showsError: !errors.isEmpty)

// Tier 3 — component: owns layout + behavior
PingSecureField(label: "Password", text: $pw, isVisible: $show)
```

What each step up buys:

- **Direct tokens = correct vocabulary.** The call site stays transparent — you can read what a view looks like without leaving the file. Right for one-off styling and unique layouts (one-off glyph sizes outside the `Glyph` scale, for instance).
- **Modifiers = pre-built sentences.** Four attributes and one conditional decision (`showsError ? statusError : separator`) written once, so every caller gets the same sentence. One `fieldRadius` decision lives in one place — before this system, "a rounded box" was hand-typed as 8/10/12/15/16 across 55 files.
- **Components = impossible-to-get-wrong combinations.** `PingIconTile` makes the dark-mode contrast pairing unachievable to get wrong because callers can't see the pieces.

**Calibration loop:** tiers are built only when convergence happens. `pingCardStyle` was deleted in round one as dead API (zero consumers), then reinstated in round two when ~15 real consumers appeared. Delete-then-reinstate is the discipline working, not failing.

---

## 4. Token reference

All tokens live in `PingTheme` in `Sources/PingDesignSystem/`. Every member has a doc comment in code; this section is the formatted view.

### 4.1 `PingTheme.Color`

| Token | Value | Use for |
|---|---|---|
| `appBackground` | `.systemGroupedBackground` | Full-screen grouped background. |
| `groupedSurface` | `.secondarySystemGroupedBackground` | Cards and secondary containers. |
| `inputSurface` | Light `#FFFFFF` / dark `#1C1C1E` | Fill behind editable text controls (stands out against the grouped screen background). |
| `contentPrimary` | `.primary` | Primary content color. |
| `contentSecondary` | `.secondary` | Supporting copy. |
| `contentTertiary` | `.tertiaryLabel` | De-emphasized content one step below `contentSecondary`. |
| `contentInverse` | `.white` | Content on action surfaces and brand-colored imagery. |
| `separator` | `.separator` | Separators and non-error borders. |
| `actionPrimary` | dynamic `#A31300` (light) / `#FFB4A8` (dark) | Primary action surface. |
| `actionPrimaryForeground` | dynamic `#FFFFFF` / `#3A0700` | The foreground paired with `actionPrimary`. |
| `actionPrimaryPressed` | dynamic `#A31300`→`#7D0F00` (light), `#FFB4A8`→`#FFDAD4` (dark) | Pressed primary-action surface. |
| `actionDisabled` | `.tertiarySystemFill` | Disabled-action surface. |
| `statusError` | `.systemRed` | Validation and error feedback. |
| `statusWarning` | `.systemOrange` | Non-blocking caution. |
| `statusSuccess` | `.systemGreen` | Positive status. |
| `statusInfo` | `.systemBlue` | In-progress/informational **status readouts** — never spinner tints. |

All colors are appearance-adaptive: the system colors and the dynamic pairs re-resolve on light/dark changes automatically.

### 4.2 `PingTheme.Typography`

Dynamic Type-safe text roles — always prefer these over fixed sizes.

| Token | Value | Use for |
|---|---|---|
| `screenTitle` | `.title2.weight(.semibold)` | Screen-level titles. |
| `display` | 28pt bold | Branded hero banner titles (main-menu header). |
| `sectionTitle` | `.subheadline.weight(.semibold)` | Form-field labels, grouped sections. |
| `body` | `.body` | Default body copy. |
| `supporting` | `.footnote` | Supporting copy, validation messages. |
| `caption` | `.caption` | Compact metadata, captions. |
| `action` | `.headline` | Action-button labels (applied by `PingActionButtonStyle`). |
| `code` | 48pt bold monospaced | Hero one-time-passcode displays only. |
| `codeSmall` | 28pt bold monospaced | Compact code displays on account cards. |
| `codeLarge` | 32pt bold | Bold numerals in countdown/ring data displays. |
| `monospacedCaption` | `.footnote` monospaced | Device IDs, tokens, raw metadata. |

### 4.3 `PingTheme.Spacing`

| Token | Value |
|---|---|
| `xxSmall` | 2 — tightest rhythm (title/subtitle gap) |
| `xSmall` | 4 |
| `small` | 8 |
| `compact` | 12 — between `small` and `medium` (grid/list item rhythm) |
| `medium` | 16 |
| `large` | 20 |
| `screen` | 20 — default screen/auth edge inset |
| `scrollBottomInset` | 30 — scroll-content bottom clearance; hand-typing this value is forbidden, use `.pingScrollContentPadding()` |

### 4.4 `PingTheme.Shape`

| Token | Value | Use for |
|---|---|---|
| `cardRadius` | 12 | Cards, action buttons. |
| `fieldRadius` | 8 | Text inputs, outlined containers, small chips. |
| `tileRadius` | 10 | Icon tiles and badges. |
| `largeCardRadius` | 16 | `pingCardStyle(size: .large)`. |
| `pillRadius` | 20 | Pills, segmented selections. |
| `borderWidth` | 1 | Input and outlined-control borders. |

### 4.5 `PingTheme.Control`

| Token | Value | Use for |
|---|---|---|
| `minimumHeight` | 50 | Minimum tappable-action height. |
| `fieldPadding` | 14 | Horizontal inset inside inputs/actions. |
| `iconSize` | 100 | Branding-image size on auth screens; circular avatars. |
| `readableContentWidth` | 560 | Max readable form width on iPad. |
| `infoRowDividerInset` | 100 | Leading inset for a `Divider()` under a label-and-value info row, aligning it past the label column. |
| `Glyph.small` | 16 | Inline badge/status glyphs (`Image(systemName:)` sizing). |
| `Glyph.medium` | 24 | Toolbar and inline action glyphs. |
| `Glyph.large` | 40 | Large section-header glyphs. |
| `Glyph.hero` | 60 | Hero decorative glyphs on empty/idle/result states. |
| `Glyph.heroLarge` | 64 | Oversized hero glyphs on full-screen status cards. |

`Glyph` sizes are for SF Symbol sizing (`.font(.system(size:))` on an `Image`), not text. One-off glyph sizes that match no token (12–15pt micro-badges, 20–22pt controls, 48pt result glyphs) stay raw at the call site.

**Two glyph-sizing conventions, by context:**
- **Standalone glyph** (hero art, badges, decorative states): a fixed `Control.Glyph.*` token. Does not scale with Dynamic Type — intentional for decorative imagery whose layout must stay stable.
- **Inline glyph** (an icon beside text it belongs to — toolbar icons, scan buttons, in-row indicators): size it with the *neighboring text's* Typography role (`.font(PingTheme.Typography.sectionTitle)` on the `Image`). Symbols sized via a text style participate in Dynamic Type and stay optically matched to their label at every text size. Never use a text-role *modifier* (`pingSectionHeader()` etc.) on a glyph — those set a text color, and inline glyphs carry their own semantic color.

---

## 5. Modifiers reference

All modifiers are `View` extensions in `Sources/PingDesignSystem/`.

### 5.1 `pingTextFieldStyle(showsError:)`

The visual surface for any editable text control: `fieldPadding` inset, `inputSurface` fill, `fieldRadius` clip, and a border that switches `separator → statusError` when `showsError` is true.

```swift
TextField("Username", text: $username)
    .pingTextFieldStyle(showsError: !errors.isEmpty)
```

- **Does not configure**: keyboard, capitalization, autocorrection, content type, submission. Opt in at the call site based on the field's meaning.
- **Wire `showsError` to real validation state** where it exists. Never invent new error wiring to fill the parameter — preserve current behavior.

### 5.2 `pingOutlinedContainerStyle(showsError:)`

The stroke-only sibling of §5.1 — same border behavior, no background fill. For controls that own their surface: checkbox/radio rows, dropdown/combobox menus, pickers.

```swift
Menu { ... } label: { ... }
    .pingOutlinedContainerStyle(showsError: !isValid)
```

### 5.3 `pingCardStyle(size:)`

The elevated grouped-card surface: padding + `groupedSurface` + radius + soft shadow, in one modifier.

| Variant | Padding | Radius | Shadow |
|---|---|---|---|
| `.standard` (default) | `medium` (16) | `cardRadius` (12) | 0.05 black, radius 4, y 2 |
| `.large` | `large` (20) | `largeCardRadius` (16) | radius 6, y 3 |
| `.rowList` | horizontal `medium` (16), vertical `small` (8) | `cardRadius` (12) | 0.05 black, radius 4, y 2 |

```swift
VStack { ... }
    .pingCardStyle()                 // standard card
    // .pingCardStyle(size: .large) for hero emphasis
    // .pingCardStyle(size: .rowList) for a card whose divider-separated rows carry their own vertical padding
```

The modifier owns padding — do **not** add your own equivalent `.padding()` outside it (§2, golden rule 4's converse).

### 5.4 `pingScreenBackground()`

Full-screen `appBackground` tint. One owner per screen: apply to the screen root (`ZStack` or `ScrollView`), never both.

### 5.5 `pingSectionHeader()`

The heading/label treatment: `sectionTitle` role + `contentPrimary` color. Serves section/card headings, list-row titles, form-field labels, and callback prompts — one role for all primary-emphasis mid-size text. (Formerly `pingFieldLabelStyle`, which had an identical composition under a narrower name and was absorbed.)

```swift
Text("Journey Name").pingSectionHeader()
```

### 5.5a Text role modifiers

Five recurring font+color compositions are named roles — the most common pairings by usage count (~170 call sites). Each replaces its two-modifier form; intentional deviations (status-colored copy, muted headers, bold-weight overrides) keep `.font`/`.foregroundStyle` so the deviation stays visible.

| Modifier | Composition | Use for |
|---|---|---|
| `.pingScreenTitle()` | `screenTitle` + `contentPrimary` | The dominant heading of a screen, card, or flow step. |
| `.pingSupportingText()` | `supporting` + `contentSecondary` | De-emphasized supporting copy — the standard secondary paragraph. |
| `.pingSectionHeader()` | `sectionTitle` + `contentPrimary` | Card/section headings, list-row titles, field labels, prompts. |
| `.pingCaptionText()` | `caption` + `contentSecondary` | Micro-metadata: timestamps, counts, hints. |
| `.pingBodySecondary()` | `body` + `contentSecondary` | Notification/status message body copy, de-emphasized against its headline. |

```swift
Text("Device Authorization").pingScreenTitle()
Text("Items sync automatically.").pingSupportingText()
Text("Account details").pingSectionHeader()
Text("Last used 2m ago").pingCaptionText()
Text("Tap Approve on your other device.").pingBodySecondary()
```

Don't stack a `foregroundStyle` on top of these — the color is part of the role. When the color must vary at runtime (e.g. pass/fail indicators) or the weight differs (`.fontWeight` chains), that's the two-modifier form, not a parameter.

### 5.6 `pingReadableContentWidth()`

Caps content at `readableContentWidth` (560) on iPad; full width on iPhone. Apply after screen padding.

### 5.7 `pingScrollContentPadding(top:bottom:)`

The screen-scroll content padding recipe in one call: `screen` horizontal margin, configurable top inset (default `screen`), configurable bottom inset (default `scrollBottomInset`, so content clears the home indicator).

```swift
ScrollView {
    VStack { ... }
        .pingScrollContentPadding()                       // the common case
        // .pingScrollContentPadding(top: PingTheme.Spacing.large)          // custom top
        // .pingScrollContentPadding(top: PingTheme.Spacing.small, bottom: 0) // fixed bar follows
}
```

Pass `bottom: 0` when content doesn't need scroll clearance (e.g. a pinned action bar follows the scroll view). One call replaces the hand-typed three-line `.padding(.horizontal…)/.padding(.top…)/.padding(.bottom…)` recipe that previously drifted across 18 call sites.

### 5.8 `pingErrorAlert(errorMessage:)`

The shared "Error" alert, bound to an optional error message. One call replaces the `alert("Error", isPresented:) { Button("OK") … } message: { Text(error) }` boilerplate that had drifted into four different binding strategies across 12 screens.

```swift
.pingErrorAlert(errorMessage: $viewModel.errorMessage)
```

Dismissing the alert — via the OK button or by any other dismissal path — always clears `errorMessage`. Do not wire an additional `showError` Bool; the binding itself is the presentation state.

### 5.9 `pingStatusCardStyle(tint:)`

A tinted status-card surface sharing the standard card geometry (medium padding, `cardRadius`, soft shadow) with the surface tinted by `tint` at 10% opacity. Use for error/success/warning result banners.

```swift
VStack { … }
    .pingStatusCardStyle(tint: PingTheme.Color.statusError)
```

---

## 6. Components reference

All components live in `Sources/PingDesignSystem/`. Each owns behavior (accessibility coordination, state pairing); the caller owns data and flow. None may accept Journey callbacks, DaVinci collectors, view models, navigation state, or Ping SDK types.

### 6.1 `PingFieldMessages`

Validation messages beneath an input. Renders each non-empty message in `statusError`; **empty entries are silently dropped**; duplicate strings render both copies (indexed identity — no duplicate-ID SwiftUI warnings).

```swift
PingFieldMessages(errorMessages: errors)
```

| Caller owns | Component owns |
|---|---|
| Validation, localization, ordering, sanitization | Presentation, empty-filtering, stable identity |

### 6.2 `PingSecureField`

Password field: label, secure/plain-text entry toggled by `isVisible`, 44pt visibility toggle with explicit VoiceOver label, `privacySensitive()` field content (redacted from app switcher and captures while plain-text), error border + messages.

```swift
@State private var password = ""
@State private var showPassword = false

PingSecureField(
    label: "Password",
    text: $password,
    isVisible: $showPassword,
    errorMessages: errorMessages
)
```

| Caller owns | Component owns |
|---|---|
| Password value, validation, messages, submit handling | Visibility state, touch target, VoiceOver label, redaction |

### 6.3 `PingIconTile`

System image in a branded tile (rounded-rect or circle). Solid dynamic fill: `actionPrimary` surface + `actionPrimaryForeground` tint — dark-mode-correct by construction. This replaces every ad hoc "fixed gradient + literal white icon" pairing, which is the class of bug that lost contrast in dark mode. An optional `isLocked` badge overlays a small status-error lock disc in the bottom-trailing corner (replacing the byte-identical 12-line `ZStack` that previously lived in `OathAccountCardView` and `PushAccountCardView`).

```swift
PingIconTile(systemName: "person.fill")                              // 40pt tile, 20pt icon
PingIconTile(systemName: "faceid", diameter: 100, iconSize: 50, shape: .circle)   // avatar
PingIconTile(systemName: "clock.fill", diameter: 40, iconSize: 20, isLocked: credential.isLocked)
```

### 6.4 `PingProgressRing`

Circular determinate progress: `separator` track + trimmed arc.

```swift
PingProgressRing(progress: 0.65)                                     // default 40pt, 3pt
PingProgressRing(progress: 0.2, lineWidth: 8, diameter: 120, tint: .statusError) // locked
```

Pass `statusError` as `tint` for locked/blocked states — never hardcode a reduced-opacity red.

### 6.5 `PingInfoRow`

Read-only label/value row. Two layouts, two value styles, optional fixed label width for aligned columns.

```swift
PingInfoRow(label: "Region", value: "US-East", labelWidth: 90)
PingInfoRow(label: "Device ID", value: id, valueStyle: .monospaced, labelWidth: 90)
PingInfoRow(label: "Created", value: date, layout: .vertical)
```

### 6.6 `PingLoadingOverlay`

Full-screen dimmed scrim + centered spinner. Conditionally placed inside a `ZStack` over the loading content.

```swift
ZStack {
    content
    if viewModel.isLoading { PingLoadingOverlay() }
}
```

### 6.7 `PingLoadingSpinner`

The app's large in-content spinner (`tint` defaults to `actionPrimary`). Replaces the `ProgressView + progressViewStyle + scaleEffect` boilerplate that previously appeared at 14 call sites — some tinted, some not, inconsistently. Unlike `PingLoadingOverlay`, it has no dimming backdrop: use it *inline* (e.g. centered in an empty screen or list) rather than over content the user shouldn't interact with.

```swift
PingLoadingSpinner()                                   // brand-tinted, the common case
PingLoadingSpinner(tint: PingTheme.Color.contentInverse)  // custom tint when on a colored surface
```

### 6.7b `EmptyStateView`

The standard empty-state composition: icon, title, optional subtitle, optional action buttons. The component owns the shared `screen` horizontal edge inset — call sites add no padding of their own (vertical centering is `PingCenteredScrollContent`'s job, so the component deliberately adds no vertical padding).

```swift
EmptyStateView(
    icon: "tray",
    title: "No Items",
    subtitle: "Items will appear here."
) {
    Button("Add Item") { … }
        .buttonStyle(.pingPrimary)
}
```

| Caller owns | Component owns |
|---|---|
| Strings, action buttons, presentation timing | Composition, edge inset, Dynamic Type roles |

### 6.8 `PingCenteredScrollContent`

Owns a `ScrollView` and vertically centers a single non-scrolling view (typically an `EmptyStateView`) within its viewport, via a `GeometryReader` that wraps — not sits inside — the `ScrollView`. Lives in `EmptyStateView.swift`. Refresh modifiers applied above reach the owned `ScrollView` through the environment, so `.refreshable` keeps working while the list is empty.

**Branch at the same level; never nest it inside a `ScrollView`.** A `GeometryReader` inside a `ScrollView` is proposed unbounded height, collapses to ~0, and pins its content to the top — the bug this component's first version shipped with. Use it as the empty/loading branch *instead of* the `ScrollView`, not within it:

```swift
ZStack {
    if items.isEmpty {
        PingCenteredScrollContent { EmptyStateView(icon: "tray", title: "No Items") }
    } else {
        ScrollView {
            VStack { /* rows */ }
                .pingScrollContentPadding()
        }
    }
}
.refreshable { await viewModel.reload() }
```

When a screen has a persistent header (device-token card, type picker), wrap the header and the branches in one `VStack(spacing: 0)` — the empty state then centers in the remaining space below the header, not the whole screen.

### 6.9 `PingChallengeNumberButton`

Outlined circular number button for MFA/DaVinci number challenges. Real `Button` with 80pt target and tap wiring.

```swift
PingChallengeNumberButton(number: 42) { select(42) }
```

### 6.10 `PingStepBadge`

Small filled circular step number for numbered instructional callouts.

```swift
PingStepBadge(number: 1)
```

---

## 7. Buttons: roles and states

All buttons are standard SwiftUI `Button`s with a semantic role. The style expands horizontally, keeps a 50pt minimum height, wraps long server-provided labels, and owns pressed + disabled treatment for every role.

### 7.1 Roles

| Role | Style | Use for | Real consumers |
|---|---|---|---|
| Primary | `.pingPrimary` | Dominant action that advances the flow | Continue, Start, Get Token |
| Secondary | `.pingSecondary` | Lower-emphasis alternative or recovery | Cancel, Try Again, Retry |
| Destructive | `.pingDestructive` | Irreversible/data-removal | Delete, Deny, Log Out, Cancel auth |
| Affirmative | `.pingAffirmative` | Confirming a positive outcome | Approve, Authenticate, valid Confirm |
| Provider | `PingActionButtonStyle(role: .provider(background:foreground:))` | Provider-branded action | Apple/Google/Facebook sign-in |

Provider carve-out: **color selection stays caller-decided** (`SocialButtonView`'s provider switch, backed by the frozen provider aliases — §9); the role shares only shape, pressed, and disabled mechanics.

### 7.2 State matrix

| Role | Resting | Pressed | Disabled |
|---|---|---|---|
| Primary | `actionPrimary` + `actionPrimaryForeground` | `actionPrimaryPressed` | `actionDisabled` + `contentSecondary` |
| Secondary | `groupedSurface` + `actionPrimary` outline/foreground | 0.86 opacity | `groupedSurface` + `separator` outline + `contentSecondary` |
| Destructive | `statusError` + `contentInverse` | Reduced opacity | `actionDisabled` + `contentSecondary` |
| Affirmative | `statusSuccess` + `contentInverse` | Reduced opacity | `actionDisabled` + `contentSecondary` |
| Provider | Caller bg + caller fg | Reduced opacity | `actionDisabled` + `contentSecondary` |

### 7.3 Rules

- **Disable with `.disabled(condition)`.** Never hand-roll a gray ternary — every role owns its disabled treatment.
- **In-flight async auth disables the button** (e.g. `SocialButtonView`'s `.disabled(isAuthenticating)`) — prevents re-entrancy.
- Labels wrap for long server-provided/localized text; minimum 50pt visual height.
- Don't add looping/automatic animation to feedback states; the pressed transition is short and non-essential.

---

## 8. Design decisions

Each decision records the defect class it closes. These are load-bearing — changing one means re-deriving the tokens that depend on it.

### D1 — Semantic tokens over raw values

**Decision:** every color/font/size comes from `PingTheme`. Raw values are forbidden outside `Sources/PingDesignSystem/`.

**Why:** before the system, "a rounded box" had 4+ hand-typed radii (8/10/12/15/16) across 55 files; one hard-coded shadow appeared verbatim 14+ times; status semantics were unsearchable (which red is *the* error?). Tokens make intent greppable and change one-point-of-change.

### D2 — Dynamic dynamic action pairing; solid tints, not gradients

**Decision:** `actionPrimary`/`actionPrimaryForeground`/`actionPrimaryPressed` are explicit dynamic pairs (light/dark). No component or modifier pairs an action color with a foreground other than these. Icon tiles use a solid dynamic fill, never the old two-color gradient.

**Why:** the old fixed `#A31300` + hardcoded `.white` pairing lost contrast in dark mode. It happened at minimum three separate times in ad hoc call sites (social buttons, push avatar, jailbreak banner) before being closed by construction. A gradient's dark stop is a fixed color; it cannot adapt. Solid dynamic tints can.

### D3 — Button roles carry state semantics

**Decision:** `PingButtonRole` = `primary` / `secondary` / `destructive` / `affirmative` / `provider(background:foreground:)`. One `ButtonStyle`, switches per role.

**Why:** before destructive/affirmative existed, "Log Out" rendered visually identical to "Continue" — a real gap, not hypothetical. The provider case exists so provider *branding* stays caller-decided while provider buttons gain real pressed feedback and disabled treatment (the hand-rolled social button had none, and stayed tappable during in-flight auth).

**History:** `.destructive` was deleted in round one as dead API (SwiftUI's own `Button(role:)` used elsewhere is a different type), then reinstated when `LogOutView`/`DeleteButton` appeared as real consumers.

### D4 — `statusInfo` is for status readouts; spinners are `actionPrimary`

**Decision:** blue appears only as in-progress **text** ("Migrating…", "Pending"). Loading-indicator tints are `actionPrimary`.

**Why:** a confirm-flow spinner was accidentally tinted `.red` — it looked like an error but meant "waiting." The rule closes that confusion by making the distinction semantic.

### D5 — Styling is visual-only; behavior is at the call site

**Decision:** `pingTextFieldStyle` never sets keyboard type, capitalization, autocorrection, content type, or submission.

**Why:** each app-owned field's input behavior follows from its meaning (a URL field, a username, a PIN). Centralizing it would force defaults that are wrong per field and hide the decisions from the reader.

### D6 — Components own defensive logic

**Decision:** `PingFieldMessages` filters empty entries and uses indexed identity; `PingSecureField` marks content `privacySensitive()` and exposes explicit VoiceOver labels; tap targets ≥ 44pt.

**Why:** duplicated validation copy collided under `id: \.self` (runtime warnings, unstable animation); empty strings rendered as empty error rows; passwords leaked into app-switcher snapshots. The component owning the fix means every future caller inherits it.

### D7 — Monospaced data has dedicated roles

**Decision:** `Typography.code` (48pt hero), `codeSmall` (28pt card codes), `codeLarge` (32pt ring numerals), and `monospacedCaption` (footnote) cover every recurring monospaced/bold-numeral display. Only single-site sizes with no second consumer stay raw.

**Why:** hero codes, device IDs, and payload text were declared with 5+ independent raw `Font.system(...design: .monospaced)` declarations. Roles make the presentation system-owned; genuine one-offs stay local rather than inflating the shared namespace (§10).

### D8 — Incubated app-locally, then extracted

**Decision:** the system incubated as app-local code in PingExample until every screen used it (§10's criteria), then extracted into this Swift package. Consumer apps import it via the `PingDesignSystem` product.

**Why:** building an SPM package from day one would have versioned API nobody had exercised. Incubation first let the API be calibrated against real screens (the delete-then-reinstate cycle of `pingCardStyle` was the calibration loop working); extraction happened only after the system was proven throughout PingExample.

---

## 9. Documented exceptions

These raw usages are deliberate. Each is functional, not stylistic — a change here is a functional decision, not a style cleanup.

| Exception | Where | Why |
|---|---|---|
| Camera scrim `Color.black.opacity(0.7)` | `QRScannerContainerView`, `PingOneMFAScannerContainerView` | Functional viewfinder contrast for QR scanning. |
| White QR backing `Color.white` | `DeviceFlowView` (wrapping its QR display) | QR decoders require light backgrounds; dark-mode tinting breaks scanning. |
| Hero `LinearGradient` on the main-menu banner | `ContentView` header | Brands the header with the repartnered dynamic accent pair; solid tints cannot express the two-stop fade. |
| AccentColor asset (`#A31300` / `#FFB4A8`) | `Assets.xcassets/AccentColor.colorset` | Mirrors `actionPrimary` so *system* controls (menus, segmented pickers, toggles, steppers) render Ping red without per-site `.tint`. |
| Lock glyph `.white` on `statusError` fill | `PingIconTile`'s `isLocked` badge | Status badge on a solid status-error disc — pairing is owned by the component. |
| Loading scrim `Color.black.opacity(0.4)` inside `PingLoadingOverlay` | `DesignSystem` internal | The component's implementation. |
| `contentInverse = .white` | `DesignSystem` definition | The inverse-content token itself. |
| Commented-out code | various | Dead code, not styling — untouched. |

---

## 10. Extending the system

When converting files surfaces a gap, update the system — that's the standing instruction. But calibrate before adding.

### Adding a token

1. Grep first: does the value already exist under a different name? Reuse beats new.
2. Does it recur 2+ times across the app? If it's a genuine one-off, make it a well-named local `private let` in that file, not a shared token.
3. Add it to `PingTheme` with a doc comment, then to this README's table (§4).

### Adding a modifier

A parameterized modifier earns existence when a *combination* (several attributes + one decision) recurs across call sites whose shapes vary. If the shape is identical everywhere too, it's a component candidate.

### Adding a component

The gate (from DESIGN_SYSTEM.md): **three or more flows converge on identical composition *and* it owns behavior** (accessibility coordination, redaction) — not mere visual ordering. If it's just `VStack` + tokens + modifiers, compose directly at the call site.

### Process for both humans and AI

1. Extend `Sources/PingDesignSystem/` first (tokens → modifiers → components, in that order).
2. Update this README (reference sections) and DESIGN_SYSTEM.md (contracts/tables) in the same change.
3. Extend the preview catalog at the bottom of `Sources/PingDesignSystem/` — one block per new API, verified in light and dark.
4. Build the package: `xcodebuild build -scheme PingDesignSystem -destination "generic/platform=iOS Simulator"` from the package root, then build each consumer app to verify.

### Known gaps (honest ledger)

- **No automated enforcement.** The rules are convention, not law — a SwiftLint custom rule banning raw styling in consumer apps is the highest-value next step.
- **No test coverage in the package.** Design-system logic is verified only by compilation and the catalog preview; token smoke tests are a follow-up.
- **Localization.** `PingSecureField`'s VoiceOver labels are English-only; app-wide localization infrastructure is a follow-up.
- **The preview catalog covers roles/components, not the full matrix** (accessibility Dynamic Type × iPad widths) — extend the catalog as the consumer matrix grows.
