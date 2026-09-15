//
//  PingCatalogPreviews
//  PingDesignSystem
//
//  Copyright (c) 2025 - 2026 Ping Identity Corporation. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

import SwiftUI

// MARK: - Preview catalog

/// One-page showcase of the entire design system: every token, role, style,
/// and component, each presented under an explanatory heading. Toggle light /
/// dark appearance and Dynamic Type in the canvas to verify both appear.
private struct PingThemeCatalogView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PingTheme.Spacing.large) {
                introduction
                section("Semantic colors", showsDivider: false) {
                    Text("Use `PingTheme.Color` tokens instead of raw RGB. System surfaces adapt to light/dark; Ping action colors keep intentional contrast in both.")
                        .pingSupportingText()
                    colorSwatch("appBackground", PingTheme.Color.appBackground, showBorder: true)
                    colorSwatch("groupedSurface", PingTheme.Color.groupedSurface, showBorder: true)
                    colorSwatch("inputSurface", PingTheme.Color.inputSurface, showBorder: true)
                    colorSwatch("contentPrimary — text", PingTheme.Color.contentPrimary, showBorder: true)
                    colorSwatch("contentSecondary — supporting copy", PingTheme.Color.contentSecondary, showBorder: true)
                    colorSwatch("contentTertiary — de-emphasized", PingTheme.Color.contentTertiary, showBorder: true)
                    colorSwatch("separator — borders and dividers", PingTheme.Color.separator, showBorder: true)
                    colorSwatch("actionPrimary — main flow action", PingTheme.Color.actionPrimary)
                    colorSwatch("actionPrimaryPressed", PingTheme.Color.actionPrimaryPressed)
                    colorSwatch("actionPrimaryForeground — on-action text", PingTheme.Color.actionPrimaryForeground)
                    colorSwatch("actionDisabled", PingTheme.Color.actionDisabled, showBorder: true)
                    colorSwatch("statusError", PingTheme.Color.statusError)
                    colorSwatch("statusWarning", PingTheme.Color.statusWarning)
                    colorSwatch("statusSuccess", PingTheme.Color.statusSuccess)
                    colorSwatch("statusInfo — in-progress readouts", PingTheme.Color.statusInfo)
                }

                section("Brand colors — fixed, appearance-invariant") {
                    Text("Identity-provider surfaces. Never theme-adaptive; selection stays at the call site via `PingActionButtonStyle(role: .provider(...))`.")
                        .pingSupportingText()
                    colorSwatch("brandApple", PingTheme.Color.brandApple, showBorder: true)
                    colorSwatch("brandGoogle", PingTheme.Color.brandGoogle)
                    colorSwatch("brandFacebook", PingTheme.Color.brandFacebook)
                }

                section("Typography roles — Dynamic Type safe") {
                    Text("Sizes scale with the user's text settings; pair with the text-role modifiers below rather than setting fonts directly.")
                        .pingSupportingText()
                    roleSample("screenTitle", "Screen title", PingTheme.Typography.screenTitle)
                    roleSample("display", "Display", PingTheme.Typography.display)
                    roleSample("sectionTitle", "Section title / field label", PingTheme.Typography.sectionTitle)
                    roleSample("body", "Body copy", PingTheme.Typography.body)
                    roleSample("supporting", "Supporting copy", PingTheme.Typography.supporting)
                    roleSample("caption", "Caption", PingTheme.Typography.caption)
                    roleSample("action", "Action label", PingTheme.Typography.action)
                    roleSample("code", "482913", PingTheme.Typography.code)
                    roleSample("codeSmall", "482913", PingTheme.Typography.codeSmall)
                    roleSample("codeLarge", "482913", PingTheme.Typography.codeLarge)
                    roleSample("monospacedCaption", "monospaced token / id", PingTheme.Typography.monospacedCaption)
                }

                section("Text-role modifiers") {
                    Text("Each pairs a font with its semantic content color in one call.")
                        .pingSupportingText()
                    Text("pingScreenTitle() — screen-level headings")
                        .pingScreenTitle()
                    Text("pingSectionHeader() — card headings, field labels")
                        .pingSectionHeader()
                    Text("pingSupportingText() — supporting copy")
                        .pingSupportingText()
                    Text("pingCaptionText() — captions and metadata")
                        .pingCaptionText()
                    Text("pingBodySecondary() — secondary body copy")
                        .pingBodySecondary()
                }

                section("Spacing — 2 / 4 / 8 / 12 / 16 / 20, screen inset 20") {
                    ForEach(
                        [
                            ("xxSmall", PingTheme.Spacing.xxSmall),
                            ("xSmall", PingTheme.Spacing.xSmall),
                            ("small", PingTheme.Spacing.small),
                            ("compact", PingTheme.Spacing.compact),
                            ("medium", PingTheme.Spacing.medium),
                            ("large", PingTheme.Spacing.large),
                        ],
                        id: \.0
                    ) { name, value in
                        HStack(spacing: PingTheme.Spacing.small) {
                            Rectangle()
                                .fill(PingTheme.Color.actionPrimary)
                                .frame(width: value, height: value)
                            Text("\(name) = \(Int(value))")
                                .pingSupportingText()
                        }
                    }
                }

                section("Shape radii") {
                    HStack(spacing: PingTheme.Spacing.small) {
                        radiusSwatch("field", PingTheme.Shape.fieldRadius)
                        radiusSwatch("tile", PingTheme.Shape.tileRadius)
                        radiusSwatch("card", PingTheme.Shape.cardRadius)
                        radiusSwatch("largeCard", PingTheme.Shape.largeCardRadius)
                        radiusSwatch("pill", PingTheme.Shape.pillRadius)
                    }
                }

                section("Button roles and states") {
                    Text("`.pingPrimary` for the dominant action, `.pingSecondary` for lower-emphasis alternatives, `.pingDestructive` for irreversible actions, `.pingAffirmative` for confirming actions, `.provider(...)` for provider-branded surfaces.")
                        .pingSupportingText()
                    Button("Continue — primary") {}
                        .buttonStyle(.pingPrimary)
                    Button("Continue — primary, pressed state via long-press") {}
                        .buttonStyle(.pingPrimary)
                    Button("Secondary") {}
                        .buttonStyle(.pingSecondary)
                    Button("Secondary — disabled") {}
                        .buttonStyle(.pingSecondary)
                        .disabled(true)
                    Button("Delete Account — destructive") {}
                        .buttonStyle(.pingDestructive)
                    Button("Approve — affirmative") {}
                        .buttonStyle(.pingAffirmative)
                    Button("Sign in with Apple") {}
                        .buttonStyle(PingActionButtonStyle(role: .provider(
                            background: PingTheme.Color.brandApple,
                            foreground: .white
                        )))
                }

                section("Cards") {
                    Text("`.pingCardStyle()` elevates content on the grouped background. `.rowList` is for cards whose rows carry their own padding; `.large` for hero/emphasis cards.")
                        .pingSupportingText()
                    VStack(alignment: .leading, spacing: PingTheme.Spacing.small) {
                        Text("Standard card").pingSectionHeader()
                        Text("The default elevated surface for grouped content.")
                            .pingSupportingText()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .pingCardStyle()

                    VStack(alignment: .leading, spacing: PingTheme.Spacing.small) {
                        Text("Large card").pingSectionHeader()
                        Text("Hero/emphasis variant with a taller radius and shadow.")
                            .pingSupportingText()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .pingCardStyle(size: .large)

                    VStack(spacing: 0) {
                        PingInfoRow(label: "Row List card", value: "rows own padding", labelWidth: 110)
                        Divider().padding(.leading, PingTheme.Control.infoRowDividerInset - PingTheme.Control.fieldPadding)
                        PingInfoRow(label: "Divider inset", value: "infoRowDividerInset", valueStyle: .monospaced, labelWidth: 110)
                    }
                    .pingCardStyle(size: .rowList)
                }

                section("Status card") {
                    Text("`.pingStatusCardStyle(tint:)` tints a card for error/success/warning banners.")
                        .pingSupportingText()
                    VStack(alignment: .leading, spacing: PingTheme.Spacing.small) {
                        Text("Error").font(PingTheme.Typography.body.weight(.semibold))
                        Text("The semantic error banner surface.").pingSupportingText()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .pingStatusCardStyle(tint: PingTheme.Color.statusError)
                }

                section("Text fields") {
                    Text("`.pingTextFieldStyle` is the filled input surface; `.pingOutlinedContainerStyle` is the stroke-only sibling. Both report validation via `showsError`, and `PingFieldMessages` renders the errors.")
                        .pingSupportingText()
                    VStack(alignment: .leading, spacing: PingTheme.Spacing.small) {
                        Text("Username").pingSectionHeader()
                        TextField("Username", text: .constant("vahan"))
                            .pingTextFieldStyle()
                        TextField("Username with errors", text: .constant("vahan"))
                            .pingTextFieldStyle(showsError: true)
                        PingFieldMessages(errorMessages: ["Username is required", "Password must be at least 12 characters long and include an uppercase letter."])
                    }
                    .pingCardStyle()

                    VStack(alignment: .leading, spacing: PingTheme.Spacing.small) {
                        Text("Outlined container").pingSectionHeader()
                        HStack {
                            Image(systemName: "bell")
                            Text("Checkbox rows use the outlined surface").pingSupportingText()
                        }
                    }
                    .pingOutlinedContainerStyle()
                }

                section("Secure field") {
                    Text("PingSecureField pairs the field surface with an eye-toggle and error messages.")
                        .pingSupportingText()
                    PingSecureField(
                        label: "Password",
                        text: .constant("correct horse battery staple"),
                        isVisible: .constant(false),
                        errorMessages: []
                    )
                    PingSecureField(
                        label: "Password",
                        text: .constant("correct horse battery staple"),
                        isVisible: .constant(true),
                        errorMessages: ["Password must be at least 12 characters long."]
                    )
                }

                section("Components") {
                    Text("Info rows (horizontal and vertical), icon tiles, progress rings, loading states, and the numbers-challenge pair.")
                        .pingSupportingText()
                    PingInfoRow(label: "Region", value: "US-East", labelWidth: 110)
                    PingInfoRow(label: "Device ID", value: "3F9A-22C1-88BB", valueStyle: .monospaced, labelWidth: 110)
                    PingInfoRow(label: "Created", value: "2026-08-14", layout: .vertical)

                    HStack(spacing: PingTheme.Spacing.medium) {
                        PingIconTile(systemName: "person.fill")
                        PingIconTile(systemName: "shield.fill", diameter: 80, iconSize: 40)
                        PingIconTile(systemName: "faceid", diameter: 100, iconSize: 50, shape: .circle)
                        PingIconTile(systemName: "lock.fill", isLocked: true)
                    }

                    HStack(spacing: PingTheme.Spacing.medium) {
                        PingProgressRing(progress: 0.65)
                        PingProgressRing(progress: 0.2, lineWidth: 8, diameter: 120, tint: PingTheme.Color.statusError)
                    }

                    HStack(spacing: PingTheme.Spacing.medium) {
                        PingChallengeNumberButton(number: 42) {}
                        PingStepBadge(number: 1)
                    }
                }

                section("Loading") {
                    Text("PingLoadingSpinner is the inline Ping-tinted spinner; PingLoadingOverlay is the full-screen scrim.")
                        .pingSupportingText()
                    PingLoadingSpinner()
                    ZStack {
                        Color.gray.opacity(0.2)
                            .frame(height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: PingTheme.Shape.cardRadius))
                        PingLoadingOverlay()
                    }
                }

                section("Screen & layout modifiers") {
                    Text("`.pingScreenBackground()` paints this page; `.pingScrollContentPadding()` is the scroll-inset recipe; `.pingReadableContentWidth()` caps form width on iPad; `.pingErrorAlert` replaces alert boilerplate.")
                        .pingSupportingText()
                    Text("Empty states: EmptyStateView + PingCenteredScrollContent vertically center icon/title/actions on a screen — see EmptyStateView.swift.")
                        .pingSupportingText()
                }
            }
            .padding(PingTheme.Spacing.screen)
            .padding(.bottom, PingTheme.Spacing.scrollBottomInset)
        }
        .pingScreenBackground()
        .navigationTitle("Design System")
    }

    // MARK: - Catalog building blocks

    /// Explanatory section: optional full-width divider, then an uppercase
    /// header over spaced content. The divider is skipped for the first
    /// section via `showsDivider: false`.
    private func section(
        _ title: String,
        showsDivider: Bool = true,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: PingTheme.Spacing.medium) {
            if showsDivider {
                Divider()
            }
            Text(title)
                .pingSectionHeader()
                .textCase(.uppercase)
            content()
        }
    }

    /// Intro paragraph explaining how to read the catalog.
    private var introduction: some View {
        VStack(alignment: .leading, spacing: PingTheme.Spacing.small) {
            Text("PingDesignSystem Catalog")
                .pingScreenTitle()
            Text("Every token, role, style, and component on one page. Compose with semantic values (PingTheme.*) instead of raw colors, fonts, spacing, or radii. Toggle light/dark and Dynamic Type in the canvas to verify contrast at both appearances and all text sizes.")
                .pingSupportingText()
        }
    }

    /// A typography-role sample: the role name in supporting text, the sample
    /// string rendered in that font role.
    private func roleSample(_ roleName: String, _ sample: String, _ font: Font) -> some View {
        VStack(alignment: .leading, spacing: PingTheme.Spacing.xxSmall) {
            Text("\(roleName) — \(sample)")
                .font(font)
                .foregroundStyle(PingTheme.Color.contentPrimary)
        }
    }

    /// A labeled color swatch row.
    private func colorSwatch(_ name: String, _ color: Color, showBorder: Bool = false) -> some View {
        HStack(spacing: PingTheme.Spacing.small) {
            RoundedRectangle(cornerRadius: PingTheme.Shape.fieldRadius)
                .fill(color)
                .overlay(
                    RoundedRectangle(cornerRadius: PingTheme.Shape.fieldRadius)
                        .strokeBorder(showBorder ? PingTheme.Color.separator : .clear, lineWidth: PingTheme.Shape.borderWidth)
                )
                .frame(width: PingTheme.Control.minimumHeight, height: PingTheme.Control.minimumHeight)
            Text(name)
                .pingSupportingText()
        }
    }

    /// A rounded-corner sample square labeled with its radius name.
    private func radiusSwatch(_ name: String, _ radius: CGFloat) -> some View {
        VStack(spacing: PingTheme.Spacing.xSmall) {
            RoundedRectangle(cornerRadius: radius)
                .fill(PingTheme.Color.inputSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: radius)
                        .strokeBorder(PingTheme.Color.separator, lineWidth: PingTheme.Shape.borderWidth)
                )
                .frame(width: 44, height: 44)
            Text("\(name) \(Int(radius))")
                .pingCaptionText()
        }
    }
}

#Preview("Catalog") {
    NavigationStack {
        PingThemeCatalogView()
    }
}
