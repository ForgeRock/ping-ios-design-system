//
//  PingTheme
//  PingDesignSystem
//
//  Copyright (c) 2025 - 2026 Ping Identity Corporation. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

import SwiftUI
import UIKit

/// Ping-branded semantic styling primitives for Ping SDK sample apps.
///
/// This incubation layer is iOS-only and requires iOS 16 or later. It has no
/// Ping SDK dependency: SDK-aware views compose these styles but retain their
/// own flow, validation, navigation, and persistence behavior.
///
/// Use semantic roles rather than raw values when composing a view:
///
/// ```swift
/// VStack(alignment: .leading, spacing: PingTheme.Spacing.small) {
///     Text("Username")
///         .pingSectionHeader()
///
///     TextField("Username", text: $username)
///         .pingTextFieldStyle(showsError: !errors.isEmpty)
///         .autocorrectionDisabled()
///         .textInputAutocapitalization(.never)
///
///     PingFieldMessages(errorMessages: errors)
///
///     Button("Continue") { submit() }
///         .buttonStyle(.pingPrimary)
/// }
/// ```
///
/// - Important: Extracted from PingExample into the PingDesignSystem Swift
///   package. It is not a public SDK API or a runtime theming system.
/// - Note: This is a fixed Ping-branded, iOS-only package. New code must use
///   these semantic roles instead of raw colors, spacing, radii, or local
///   button styling.
public enum PingTheme {
    /// Semantic foreground, surface, action, state, and separator colors.
    ///
    /// System surfaces and content colors adapt to the active appearance.
    /// Ping action colors use explicit iOS dynamic colors so their foreground
    /// contrast remains intentional in both light and dark appearance.
    public enum Color {
        /// The default grouped background for a full application screen.
        public static let appBackground = SwiftUI.Color(uiColor: .systemGroupedBackground)
        /// The elevated grouped surface used by cards and secondary containers.
        public static let groupedSurface = SwiftUI.Color(uiColor: .secondarySystemGroupedBackground)
        /// The fill behind editable text controls.
        ///
        /// Pure white in light appearance so fields stand out against the
        /// grouped screen background (`#F2F2F7`, which this token's previous
        /// value matched exactly, making fields invisible); the elevated
        /// dark gray in dark appearance, where the screen background is
        /// already near-black.
        public static let inputSurface = dynamic(light: 0xFFFFFF, dark: 0x1C1C1E)
        /// The primary system content color.
        public static let contentPrimary = SwiftUI.Color.primary
        /// The secondary system content color for supporting copy.
        public static let contentSecondary = SwiftUI.Color.secondary
        /// Content placed on Ping action surfaces and brand-colored imagery.
        public static let contentInverse = SwiftUI.Color.white
        /// The standard separator and non-error control border color.
        public static let separator = SwiftUI.Color(uiColor: .separator)
        /// The fixed Ping primary-action surface.
        public static let actionPrimary = dynamic(light: 0xA31300, dark: 0xFFB4A8)
        /// The contrasting foreground paired with ``actionPrimary``.
        public static let actionPrimaryForeground = dynamic(light: 0xFFFFFF, dark: 0x3A0700)
        /// The pressed Ping primary-action surface.
        public static let actionPrimaryPressed = dynamic(light: 0x7D0F00, dark: 0xFFDAD4)
        /// The surface for disabled actions.
        public static let actionDisabled = SwiftUI.Color(uiColor: .tertiarySystemFill)
        /// The semantic error color for validation and error feedback.
        public static let statusError = SwiftUI.Color(uiColor: .systemRed)
        /// The semantic warning color for non-blocking caution feedback.
        public static let statusWarning = SwiftUI.Color(uiColor: .systemOrange)
        /// The semantic success color for positive status feedback.
        public static let statusSuccess = SwiftUI.Color(uiColor: .systemGreen)
        /// The semantic color for in-progress or informational feedback.
        ///
        /// Reserved for status readouts (for example, a "Migrating…" label). A
        /// loading indicator's spinner tint should use ``actionPrimary`` instead.
        public static let statusInfo = SwiftUI.Color(uiColor: .systemBlue)
        /// De-emphasized content one step below ``contentSecondary``.
        public static let contentTertiary = SwiftUI.Color(uiColor: .tertiaryLabel)
        /// The Apple identity-provider action surface. Same value in both
        /// appearances: brand color, not theme-adaptive.
        public static let brandApple = dynamic(light: 0x000000, dark: 0x000000)
        /// The Google identity-provider action surface (legacy Ping red).
        public static let brandGoogle = dynamic(light: 0xA31300, dark: 0xA31300)
        /// The Facebook identity-provider action surface (legacy blue).
        public static let brandFacebook = dynamic(light: 0x0080FF, dark: 0x0080FF)

        private static func dynamic(light: UInt, dark: UInt) -> SwiftUI.Color {
            SwiftUI.Color(uiColor: UIColor { traits in
                let value = traits.userInterfaceStyle == .dark ? dark : light
                return UIColor(
                    red: CGFloat((value >> 16) & 0xFF) / 255,
                    green: CGFloat((value >> 8) & 0xFF) / 255,
                    blue: CGFloat(value & 0xFF) / 255,
                    alpha: 1
                )
            })
        }
    }

    /// Semantic Dynamic Type text roles.
    ///
    /// Prefer these roles over fixed point sizes so the sample remains readable
    /// at accessibility text sizes.
    public enum Typography {
        /// Heading for an authentication or screen-level title.
        public static let screenTitle = Font.title2.weight(.semibold)
        /// Hero banner title (branded main-menu header).
        public static let display = Font.system(size: 28, weight: .bold)
        /// Compact monospaced one-time-passcode role for code displays on cards.
        public static let codeSmall = Font.system(size: 28, weight: .bold, design: .monospaced)
        /// Bold numeral role for countdown/ring data displays.
        public static let codeLarge = Font.system(size: 32, weight: .bold)
        /// Label for a form field or grouped section.
        public static let sectionTitle = Font.subheadline.weight(.semibold)
        /// Default body copy.
        public static let body = Font.body
        /// Supporting copy and validation messages.
        public static let supporting = Font.footnote
        /// Compact metadata and captions.
        public static let caption = Font.caption
        /// Label for a semantic action button.
        public static let action = Font.headline
        /// Large monospaced role for hero one-time-passcode displays.
        public static let code = Font.system(size: 48, weight: .bold, design: .monospaced)
        /// Compact monospaced role for device identifiers, tokens, and raw metadata.
        public static let monospacedCaption = Font.system(.footnote, design: .monospaced)
    }

    /// Shared layout spacing values.
    public enum Spacing {
        /// Tightest rhythm, e.g. between a title and its subtitle.
        public static let xxSmall: CGFloat = 2
        public static let xSmall: CGFloat = 4
        public static let small: CGFloat = 8
        /// Between ``small`` and ``medium``, e.g. grid/list item rhythm.
        public static let compact: CGFloat = 12
        public static let medium: CGFloat = 16
        public static let large: CGFloat = 20
        /// Default edge inset for an application screen or auth container.
        public static let screen: CGFloat = 20
        /// Bottom inset for scrollable screen content, clearing the home indicator.
        public static let scrollBottomInset: CGFloat = 30
    }

    /// Shared shapes and border metrics.
    public enum Shape {
        /// Corner radius for cards and action buttons.
        public static let cardRadius: CGFloat = 12
        /// Corner radius for text input surfaces.
        public static let fieldRadius: CGFloat = 8
        /// Corner radius for icon tiles and badges.
        public static let tileRadius: CGFloat = 10
        /// Corner radius for the large ``pingCardStyle(size:)`` variant.
        public static let largeCardRadius: CGFloat = 16
        /// Corner radius for pill-shaped chips and segmented selections.
        public static let pillRadius: CGFloat = 20
        /// Standard border width for input and outlined controls.
        public static let borderWidth: CGFloat = 1
    }

    /// Standard control and readable-layout dimensions.
    public enum Control {
        /// Minimum visual height for tappable actions.
        public static let minimumHeight: CGFloat = 50
        /// Horizontal inset inside an input or action control.
        public static let fieldPadding: CGFloat = 14
        /// PingExample branding-image size within authentication screens.
        public static let iconSize: CGFloat = 100
        /// Maximum readable width for form content on wide iPad layouts.
        public static let readableContentWidth: CGFloat = 560
        /// Leading inset for a `Divider()` under a label-and-value info row,
        /// aligning it past the label column.
        public static let infoRowDividerInset: CGFloat = 100

        /// Glyph sizes for `Image(systemName:)` sizing via `.font(.system(size:))`.
        /// Not text roles — SF Symbol glyphs scale independently of Dynamic Type.
        public enum Glyph {
            /// Inline badge/status glyphs inside rows (12–16pt range).
            public static let small: CGFloat = 16
            /// Medium toolbar and inline action glyphs.
            public static let medium: CGFloat = 24
            /// Large section-header glyphs.
            public static let large: CGFloat = 40
            /// Hero decorative glyphs on empty/idle/result states.
            public static let hero: CGFloat = 60
            /// Oversized hero glyphs on full-screen status cards.
            public static let heroLarge: CGFloat = 64
        }
    }
}
