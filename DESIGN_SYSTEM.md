# Ping Design System

## Purpose

The `PingDesignSystem` Swift package gives every sample-app screen a shared Ping-branded visual language while keeping authentication SDK behavior in the Journey, DaVinci, OIDC, MFA, and management views that own it.

The package is intentionally:

- **iOS-only** and supports iOS 16 or later.
- **Fixed Ping-branded**, rather than runtime-themeable or tenant-brandable.
- **SDK-independent**: it imports SwiftUI/UIKit only and must never depend on Ping SDK node, callback, collector, storage, navigation, or workflow types.
- **Style-first**: use semantic tokens, `ButtonStyle`, and `ViewModifier` APIs before creating a reusable view.

The system was proven across PingExample (all screens, all flows) and extracted into this versioned Swift package, which PingExample and the sdk-sample-apps samples now consume.

## API tiers

### Semantic tokens

Use `PingTheme` roles rather than raw RGB values, fixed type sizes, spacing literals, radii, or control dimensions.

| Family | Use |
| --- | --- |
| `PingTheme.Color` | Semantic surfaces, content, actions, status feedback, and borders; plus fixed appearance-invariant provider brand surfaces (`brandApple`, `brandGoogle`, `brandFacebook`). |
| `PingTheme.Typography` | Dynamic Type-safe text roles. |
| `PingTheme.Spacing` | Consistent vertical and horizontal spacing. |
| `PingTheme.Shape` | Control and card geometry. |
| `PingTheme.Control` | Standard action size, input inset, branding-image size, and readable width. |

New code selects a semantic intent. For example, use `actionPrimary` for the main flow action and `statusError` for validation feedback. `statusInfo` is reserved for in-progress/informational status readouts (for example, a "Migrating…" label) — a loading indicator's spinner tint should use `actionPrimary` instead. `contentTertiary` is for content one step more de-emphasized than `contentSecondary`. `Spacing.compact` fills the rhythm between `small` and `medium` (grid/list item gaps); `Spacing.scrollBottomInset` is the scroll-content bottom clearance — hand-typing its value is forbidden, use `.pingScrollContentPadding()` instead. `Control.infoRowDividerInset` aligns a `Divider()` under label-and-value info rows past the label column. `Typography.code`/`monospacedCaption` and `Shape.tileRadius`/`largeCardRadius`/`pillRadius` cover the hero-code, metadata, icon-tile, and pill/chip cases found across the app.

### Styles and modifiers

These are the normal composition API:

```swift
TextField("Username", text: $username)
    .pingTextFieldStyle(showsError: !errors.isEmpty)
    .autocorrectionDisabled()
    .textInputAutocapitalization(.never)

Button("Continue") { submit() }
    .buttonStyle(.pingPrimary)
```

| API | Contract |
| --- | --- |
| `.pingPrimary` | Dominant flow action. Supports long labels by wrapping. |
| `.pingSecondary` | Lower-emphasis alternative/recovery action. |
| `.pingDestructive` | Irreversible or data-removal action (Delete, Deny, Log Out, Cancel). |
| `.pingAffirmative` | Confirming action for a positive outcome (Approve, Authenticate). |
| `PingActionButtonStyle(role: .provider(background:foreground:))` | Provider-branded action (Apple/Google/Facebook) with a caller-supplied surface/foreground; shares shape, pressed, and disabled treatment, but color selection stays outside this role model. |
| `.pingTextFieldStyle(showsError:)` | Visual field surface only: fill, geometry, inset, and border. It intentionally does not set keyboard, text content type, capitalization, autocorrection, or submission behavior. |
| `.pingOutlinedContainerStyle(showsError:)` | Stroke-only sibling of `.pingTextFieldStyle` for controls that already own their surface (checkbox/radio rows, dropdown/combobox menus). |
| `.pingSectionHeader()` | Primary-emphasis heading/label role — section/card headings, row titles, form-field labels, callback prompts. Absorbed the earlier `pingFieldLabelStyle` (identical composition, narrower name). |
| `.pingScreenTitle()` / `.pingSectionHeader()` / `.pingSupportingText()` / `.pingCaptionText()` / `.pingBodySecondary()` | The five named text roles (`screenTitle`+`contentPrimary`, `sectionTitle`+`contentPrimary`, `supporting`+`contentSecondary`, `caption`+`contentSecondary`, `body`+`contentSecondary`); promoted from the most frequent font+color pairings (~169 call sites). Intentional color, weight, or monospace deviations keep the two-modifier form, as do inline glyphs (roles set a text color; glyphs carry their own). |
| `.pingScreenBackground()` | Standard grouped full-screen surface. |
| `.pingCardStyle(size:)` | Elevated grouped-card surface, padding, shape, and shadow. `.standard` (default), `.large` for hero/emphasis cards, or `.rowList` for a card whose rows carry their own vertical padding. |
| `.pingStatusCardStyle(tint:)` | Tinted status-card surface (error/success/warning banners) sharing the standard card geometry, with the surface tinted by `tint`. |
| `.pingScrollContentPadding(top:bottom:)` | The screen-scroll content padding recipe: `screen` horizontal margin plus configurable top/bottom insets (defaults: `screen` / `scrollBottomInset`). One call replaces the hand-typed three-line recipe; pass `bottom: 0` when a fixed bar follows. |
| `.pingErrorAlert(errorMessage:)` | The shared "Error" alert bound to a `String?` — replaces hand-written `isPresented`/`Button("OK")`/`message` boilerplate; dismissing always clears the message. |
| `.pingReadableContentWidth()` | Full width on narrow layouts and capped readable width on iPad. |

### Reusable components

A reusable component is appropriate only when it centralizes repeated behavior or composition. A repeated visual ordering is not sufficient on its own: if a layout is just `VStack` + tokens + modifiers, compose it directly at the call site and reintroduce a shared component only when three or more flows converge on identical composition *and* it owns behavior (for example, accessibility coordination) rather than mere ordering.

| Component | Responsibility | Caller owns |
| --- | --- | --- |
| `PingFieldMessages` | Validation error presentation; empty messages are filtered. | Validation, localization, ordering, and sanitization of messages. |
| `PingSecureField` | Secure/plain-text visibility state, touch target, and VoiceOver toggle label. | Password value, validation, messages, and submit handling. |
| `PingIconTile` | Icon-in-tile/avatar surface with dark-mode-correct tint pairing (rounded-rect or circle); optional `isLocked` badge overlay. | Which system image, size, and locked state to show. |
| `PingProgressRing` | Circular determinate progress drawing (track + trimmed arc). | Progress fraction and tint (for example, `statusError` when locked). |
| `PingInfoRow` | Label/value row layout (horizontal or vertical) and typography. | The label/value strings and localization. |
| `PingLoadingOverlay` | Full-screen dimmed scrim with a centered spinner. | When to show it (the caller's own loading state, inside a `ZStack`). |
| `EmptyStateView` | Empty-state composition (icon, title, subtitle, actions) and the shared `screen` edge inset. | The icon/title/subtitle strings, action buttons, and when to show it. |
| `PingLoadingSpinner` | The shared large in-content spinner (no dimming backdrop) — replaces ad hoc `ProgressView` + style + scale boilerplate. | Where to show it inline (e.g. centered in an empty screen) and optional tint. |
| `PingCenteredScrollContent` | Owns a `ScrollView` and vertically centers a single non-scrolling view (typically an empty state) in its viewport; `.refreshable` applied above still reaches the owned `ScrollView`. Lives in `EmptyStateView.swift`. Branch between it and a plain `ScrollView` at the same level — never nest it inside a `ScrollView` (a `GeometryReader` inside a `ScrollView` collapses to zero height and the content pins to the top). | The centered content and the screen's loading/empty/data branching. |
| `PingChallengeNumberButton` | Outlined circular number button shape, touch target, and tap action wiring. | The number and what selecting it does. |
| `PingStepBadge` | Filled circular step-number badge shape and dark-mode-correct tint pairing. | The step number and surrounding instructional copy. |

No generic component may accept Journey callbacks, DaVinci collectors, a view model, navigation state, or Ping SDK types.

## Action-button state matrix

| Role | Resting | Pressed | Disabled |
| --- | --- | --- | --- |
| Primary | Ping primary surface and paired contrast foreground | Explicit Ping pressed surface | System disabled surface with secondary foreground |
| Secondary | Grouped surface with Ping outline/foreground | Reduced opacity | Grouped surface with separator outline and secondary foreground |
| Destructive | System error surface with inverse foreground | Reduced opacity | System disabled surface with secondary foreground |
| Affirmative | System success surface with inverse foreground | Reduced opacity | System disabled surface with secondary foreground |
| Provider | Caller-supplied brand surface/foreground | Reduced opacity | System disabled surface with secondary foreground |

Buttons have a minimum 50-point visual height and multiline labels so server-provided and localized actions remain legible. Provider color *selection* is outside this role model — Apple/Google/Facebook stay caller-decided — but the provider role shares this matrix's shape, pressed, and disabled mechanics so provider buttons get real pressed feedback and disabled treatment instead of a hand-rolled `Text` + `background`.

## Field contract

- Field styling is visual only; configure input behavior at the call site based on the field’s semantics.
- Username, password, redirect URI, email, and token fields may disable autocorrection/capitalization or set a keyboard/content type.
- Names and free-form text must keep the input behavior their use case needs.
- Error messages must be localized, safe to display, and supplied in the order they should be read. Known gap: the `PingSecureField` visibility-toggle VoiceOver label is currently English-only; app-wide localization infrastructure is a follow-up.
- Validation calculations and mutations remain in the callback or collector adapter.

## Accessibility and responsive behavior

- Use Dynamic Type roles; do not add fixed font sizes unless a technical datum requires monospaced presentation.
- Icon-only controls require an explicit accessibility label.
- Visibility toggles retain a 44-point tap target.
- Do not rely on color alone for validation/error meaning; messages remain visible alongside the error border.
- Verify light/dark appearance contrast, normal and accessibility Dynamic Type, long labels, and iPhone/iPad widths for every new style/component adoption.
- Respect system motion behavior. The current pressed transition is short and non-essential; do not add looping/automatic animation to feedback states.

## Brand colors

Identity-provider brand surfaces live in the token model as fixed (appearance-invariant) colors:

- `PingTheme.Color.brandApple` — Apple black (`0x000000`)
- `PingTheme.Color.brandGoogle` — legacy Ping red (`0xA31300`)
- `PingTheme.Color.brandFacebook` — Facebook blue (`0x0080FF`)

They are the same value in light and dark appearance — brand colors are owned by the provider, not theme-adaptive. `SocialButtonView`'s provider switch selects among them; the `default` branch falls back to `PingTheme.Color.actionPrimary`. The former `googleButtonBackground`/`appleButtonBackground`/`facebookButtonBackground` SwiftUI.Color aliases have been removed — a source search confirmed zero remaining consumers. The `themeButtonBackground` and `themeTextField` aliases were removed earlier for the same reason.

If a brand token's value ever needs to change, update the token — never inline the color at the call site.

## Required validation for changes

The system is proven across PingExample (all screens: Journey callbacks, DaVinci collectors, authentication flows, MFA/account management, tools/configuration, dashboard) and the sdk-sample-apps samples. Any token, modifier, or component change must be validated against every consumer app before tagging a release.

The one-page preview catalog in `Sources/PingDesignSystem/Catalog/` demonstrates:

- light and dark appearance;
- normal and accessibility Dynamic Type;
- iPhone and iPad widths;
- button roles and states;
- long labels/messages;
- secure-field visibility and validation;
- card, status, and authentication-container variants.

## Governance

1. This package repo owns the design-system API. Consumer apps must never fork, patch, or vendor package sources.
2. Every consumer-visible API change ships behind a package version tag; apps pin a version range (up-to-next-major by default).
3. No layer of this package may own SDK behavior, provider branding beyond the fixed brand tokens, host assets, or navigation.
4. Brand colors are appearance-invariant by design (see "Brand colors"); the call site selects the brand surface.
5. Platform scope stays iOS 16+; SwiftUI and UIKit are the only imports.
