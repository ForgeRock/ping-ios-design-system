//
//  PingViewModifiers
//  PingDesignSystem
//
//  Copyright (c) 2025 - 2026 Ping Identity Corporation. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//


import SwiftUI

// MARK: - View modifiers

private struct PingReadableContentWidth: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: PingTheme.Control.readableContentWidth)
            .frame(maxWidth: .infinity)
    }
}

private struct PingScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content.background(PingTheme.Color.appBackground)
    }
}

/// The shared screen-scroll content padding: `screen` horizontal margin, a
/// configurable top inset, and a configurable bottom inset.
private struct PingScrollContentPadding: ViewModifier {
    let top: CGFloat
    let bottom: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, PingTheme.Spacing.screen)
            .padding(.top, top)
            .padding(.bottom, bottom)
    }
}

/// Size variants for ``pingCardStyle(size:)``.
public enum PingCardSize {
    /// Standard grouped-card treatment: 12pt radius, medium padding, subtle shadow.
    case standard
    /// Larger treatment for hero/emphasis cards: 16pt radius, large padding, deeper shadow.
    case large
    /// For a card whose content is a list of rows that already carry their
    /// own vertical padding (e.g. divider-separated rows). Only horizontal
    /// `medium` padding is added; vertical padding is `small` so the card's
    /// top/bottom edges match the spacing between rows instead of stacking
    /// on top of each row's own padding.
    case rowList
}

private struct PingCardStyle: ViewModifier {
    let size: PingCardSize

    func body(content: Content) -> some View {
        switch size {
        case .standard:
            content
                .padding(PingTheme.Spacing.medium)
                .background(PingTheme.Color.groupedSurface)
                .clipShape(RoundedRectangle(cornerRadius: PingTheme.Shape.cardRadius))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        case .large:
            content
                .padding(PingTheme.Spacing.large)
                .background(PingTheme.Color.groupedSurface)
                .clipShape(RoundedRectangle(cornerRadius: PingTheme.Shape.largeCardRadius))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        case .rowList:
            content
                .padding(.horizontal, PingTheme.Spacing.medium)
                .padding(.vertical, PingTheme.Spacing.small)
                .background(PingTheme.Color.groupedSurface)
                .clipShape(RoundedRectangle(cornerRadius: PingTheme.Shape.cardRadius))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
}

/// A tinted card surface for a status message (error, success, warning),
/// used by ``ErrorView`` and similar result banners.
///
/// Uses the same padding, corner radius, and shadow recipe as
/// ``PingCardStyle/standard``, with the surface tinted by `tint` instead of
/// ``PingTheme/Color/groupedSurface``, so every "status card" in the app
/// shares one visual treatment regardless of which status it represents.
private struct PingStatusCardStyle: ViewModifier {
    let tint: Color

    func body(content: Content) -> some View {
        content
            .padding(PingTheme.Spacing.medium)
            .background(tint.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: PingTheme.Shape.cardRadius))
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

private struct PingTextFieldStyle: ViewModifier {
    let showsError: Bool

    func body(content: Content) -> some View {
        content
            .padding(PingTheme.Control.fieldPadding)
            .background(PingTheme.Color.inputSurface)
            .clipShape(RoundedRectangle(cornerRadius: PingTheme.Shape.fieldRadius))
            .overlay(
                RoundedRectangle(cornerRadius: PingTheme.Shape.fieldRadius)
                    .stroke(
                        showsError ? PingTheme.Color.statusError : PingTheme.Color.separator,
                        lineWidth: PingTheme.Shape.borderWidth
                    )
            )
    }
}

/// A stroke-only sibling of ``PingTextFieldStyle`` for controls that already
/// own their own surface (checkbox/radio rows, dropdown/combobox menus) and
/// only need the shared outlined-container border.
private struct PingOutlinedContainerStyle: ViewModifier {
    let showsError: Bool

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: PingTheme.Shape.fieldRadius)
                    .stroke(
                        showsError ? PingTheme.Color.statusError : PingTheme.Color.separator,
                        lineWidth: PingTheme.Shape.borderWidth
                    )
            )
    }
}

public extension View {
    /// Caps form content at the shared readable width on iPad while retaining
    /// full available width on narrow iPhone layouts.
    func pingReadableContentWidth() -> some View {
        modifier(PingReadableContentWidth())
    }

    /// Applies the semantic grouped background for a complete application screen.
    func pingScreenBackground() -> some View {
        modifier(PingScreenBackground())
    }

    /// Applies the shared screen-scroll content padding: `screen` horizontal
    /// margin, `top` inset (defaults to `screen`), and `bottom` inset
    /// (defaults to ``PingTheme/Spacing/scrollBottomInset`` so content clears
    /// the home indicator). Pass `bottom: 0` for content that doesn't need
    /// scroll clearance, e.g. because a fixed bar follows it.
    func pingScrollContentPadding(
        top: CGFloat = PingTheme.Spacing.screen,
        bottom: CGFloat = PingTheme.Spacing.scrollBottomInset
    ) -> some View {
        modifier(PingScrollContentPadding(top: top, bottom: bottom))
    }

    /// Presents the shared "Error" alert bound to a view model's optional
    /// error message — a single call replaces the isPresented/Button/Text
    /// boilerplate this app previously hand-wrote at every call site (with
    /// several sites drifting into their own binding strategy in the
    /// process). Dismissing the alert, from the OK button or otherwise,
    /// clears `errorMessage`.
    func pingErrorAlert(errorMessage: Binding<String?>) -> some View {
        alert("Error", isPresented: Binding(
            get: { errorMessage.wrappedValue != nil },
            set: { if !$0 { errorMessage.wrappedValue = nil } }
        )) {
            Button("OK", role: .cancel) { errorMessage.wrappedValue = nil }
        } message: {
            Text(errorMessage.wrappedValue ?? "")
        }
    }

    /// Applies the standard elevated grouped-card surface, padding, shape, and shadow.
    ///
    /// Callers should not layer equivalent padding or elevation unless they are
    /// deliberately opting out of the shared card geometry.
    func pingCardStyle(size: PingCardSize = .standard) -> some View {
        modifier(PingCardStyle(size: size))
    }

    /// Applies the shared tinted status-card surface, padding, shape, and shadow.
    ///
    /// - Parameter tint: The status color the card represents, e.g.
    ///   ``PingTheme/Color/statusError`` or ``PingTheme/Color/statusSuccess``.
    func pingStatusCardStyle(tint: Color) -> some View {
        modifier(PingStatusCardStyle(tint: tint))
    }

    /// Applies the visual input surface and validation border.
    ///
    /// - Parameter showsError: When `true`, draws the semantic error border.
    /// - Note: This modifier intentionally does not configure keyboard type,
    ///   capitalization, autocorrection, content type, or submission. Each
    ///   app-owned field must opt into those behaviors based on its meaning.
    func pingTextFieldStyle(showsError: Bool = false) -> some View {
        modifier(PingTextFieldStyle(showsError: showsError))
    }

    /// Applies the shared stroke-only validation border, without a background
    /// fill, for controls that already own their own surface.
    ///
    /// - Parameter showsError: When `true`, draws the semantic error border.
    func pingOutlinedContainerStyle(showsError: Bool = false) -> some View {
        modifier(PingOutlinedContainerStyle(showsError: showsError))
    }

    /// De-emphasized supporting copy — the standard secondary paragraph role
    /// (`Typography.supporting` at `contentSecondary`).
    ///
    /// The most common text composition in the app (53+ call sites at the time
    /// of promotion). Sites that intentionally deviate (e.g. status-colored
    /// supporting copy) keep the two-modifier form.
    func pingSupportingText() -> some View {
        font(PingTheme.Typography.supporting)
            .foregroundStyle(PingTheme.Color.contentSecondary)
    }

    /// Primary-emphasis heading and label role (`Typography.sectionTitle` at
    /// `contentPrimary`): section/card headings, list-row titles, form-field
    /// labels, and callback prompts.
    ///
    /// Absorbed `pingFieldLabelStyle`, which had an identical composition
    /// under a narrower name — one role, one name.
    func pingSectionHeader() -> some View {
        font(PingTheme.Typography.sectionTitle)
            .foregroundStyle(PingTheme.Color.contentPrimary)
    }

    /// Screen-level title (`Typography.screenTitle` at `contentPrimary`) —
    /// the dominant heading of a screen, card, or flow step.
    func pingScreenTitle() -> some View {
        font(PingTheme.Typography.screenTitle)
            .foregroundStyle(PingTheme.Color.contentPrimary)
    }

    /// Compact de-emphasized metadata (`Typography.caption` at
    /// `contentSecondary`) — timestamps, counts, hints.
    func pingCaptionText() -> some View {
        font(PingTheme.Typography.caption)
            .foregroundStyle(PingTheme.Color.contentSecondary)
    }

    /// Notification and status message body copy (`Typography.body` at
    /// `contentSecondary`) — the message text of push notifications, status
    /// cards, and inline callouts, de-emphasized against the headline.
    func pingBodySecondary() -> some View {
        font(PingTheme.Typography.body)
            .foregroundStyle(PingTheme.Color.contentSecondary)
    }
}
