//
//  EmptyStateView.swift
//  PingDesignSystem
//
//  Copyright (c) 2025 - 2026 Ping Identity Corporation. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//


import SwiftUI

/// A reusable empty state view with an icon, title, optional subtitle,
/// and optional action content (e.g. buttons).
public struct EmptyStateView<Actions: View>: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let actions: Actions

    public init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        @ViewBuilder actions: () -> Actions
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actions = actions()
    }

    public var body: some View {
        VStack(spacing: PingTheme.Spacing.large) {
            Image(systemName: icon)
                .font(.system(size: PingTheme.Control.Glyph.hero))
                .foregroundStyle(PingTheme.Color.contentSecondary)
                .padding()

            Text(title)
                .pingScreenTitle()

            if let subtitle {
                Text(subtitle)
                    .pingSupportingText()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            actions
        }
        // Component-owned edge inset so every empty state sits at the shared
        // `screen` margin regardless of call site. Vertical spacing is not
        // added here: empty states are centered (see PingCenteredScrollContent).
        .padding(.horizontal, PingTheme.Spacing.screen)
    }
}

extension EmptyStateView where Actions == EmptyView {
    public init(icon: String, title: String, subtitle: String? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actions = EmptyView()
    }
}

/// Owns a `ScrollView` and vertically centers `content` within its visible
/// viewport — for a screen whose content when empty is a single non-scrolling
/// view (typically an ``EmptyStateView``).
///
/// The `GeometryReader` wraps the `ScrollView` rather than sitting inside it:
/// a `GeometryReader` inside a `ScrollView` is proposed unbounded height,
/// collapses to ~0, and its content pins to the top instead of centering.
/// Refresh modifiers applied above this view reach the owned `ScrollView`
/// through the environment, so `.refreshable` keeps working while empty.
/// Branch between this component (empty/loading) and a plain `ScrollView`
/// (data) at the same level; do not nest it inside a `ScrollView`.
public struct PingCenteredScrollContent<Content: View>: View {
    @ViewBuilder var content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollView {
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .frame(minHeight: proxy.size.height)
            }
        }
    }
}
