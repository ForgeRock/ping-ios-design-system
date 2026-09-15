//
//  PingButtonStyles
//  PingDesignSystem
//
//  Copyright (c) 2025 - 2026 Ping Identity Corporation. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//


import SwiftUI

// MARK: - Button styles

/// Semantic action roles for PingExample buttons.
public enum PingButtonRole: Equatable {
    /// The dominant action that advances the current flow.
    case primary
    /// A lower-emphasis alternative or recovery action.
    case secondary
    /// An irreversible or data-removal action.
    case destructive
    /// A confirming action for a positive outcome (approve, authenticate).
    case affirmative
    /// A provider-branded action (Apple, Google, Facebook) with a
    /// caller-supplied surface and foreground. Provider color selection stays
    /// outside this role model; only the shape/pressed/disabled treatment is shared.
    case provider(background: SwiftUI.Color, foreground: SwiftUI.Color)
}

/// Applies a semantic Ping action treatment to a standard SwiftUI `Button`.
///
/// The label may wrap for long localized or server-provided text. The button
/// expands horizontally and grows vertically when necessary, while retaining a
/// 50-point minimum height. Its state treatment is:
///
/// | Role | Resting | Pressed | Disabled |
/// | --- | --- | --- | --- |
/// | Primary | Ping primary surface | Darker/lightened Ping pressed surface | Disabled system fill with secondary content |
/// | Secondary | Grouped surface with Ping outline | Reduced opacity | Grouped surface with muted outline/content |
/// | Destructive | System error surface | Reduced opacity | Disabled system fill with secondary content |
/// | Affirmative | System success surface | Reduced opacity | Disabled system fill with secondary content |
/// | Provider | Caller-supplied brand surface | Reduced opacity | Disabled system fill with secondary content |
///
/// - Note: SwiftUI supplies the pressed state. Keyboard focus styling is owned
///   by the system on iOS.
public struct PingActionButtonStyle: SwiftUI.ButtonStyle {
    /// The semantic role that determines the button's state appearance.
    public let role: PingButtonRole

    public init(role: PingButtonRole) {
        self.role = role
    }

    @Environment(\.isEnabled) private var isEnabled

    public func makeBody(configuration: SwiftUI.ButtonStyleConfiguration) -> some View {
        configuration.label
            .font(PingTheme.Typography.action)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: PingTheme.Control.minimumHeight)
            .padding(.horizontal, PingTheme.Control.fieldPadding)
            .foregroundStyle(foregroundColor)
            .background(backgroundColor(isPressed: configuration.isPressed))
            .clipShape(RoundedRectangle(cornerRadius: PingTheme.Shape.cardRadius))
            .overlay(border)
            .opacity(configuration.isPressed && isEnabled && role != .primary ? 0.86 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    private var foregroundColor: SwiftUI.Color {
        guard isEnabled else { return PingTheme.Color.contentSecondary }

        switch role {
        case .primary:
            return PingTheme.Color.actionPrimaryForeground
        case .secondary:
            return PingTheme.Color.actionPrimary
        case .destructive, .affirmative:
            return PingTheme.Color.contentInverse
        case .provider(_, let foreground):
            return foreground
        }
    }

    private func backgroundColor(isPressed: Bool) -> SwiftUI.Color {
        guard isEnabled else { return PingTheme.Color.actionDisabled }

        switch role {
        case .primary:
            return isPressed ? PingTheme.Color.actionPrimaryPressed : PingTheme.Color.actionPrimary
        case .secondary:
            return PingTheme.Color.groupedSurface
        case .destructive:
            return PingTheme.Color.statusError
        case .affirmative:
            return PingTheme.Color.statusSuccess
        case .provider(let background, _):
            return background
        }
    }

    @ViewBuilder
    private var border: some View {
        if role == .secondary {
            RoundedRectangle(cornerRadius: PingTheme.Shape.cardRadius)
                .stroke(
                    isEnabled ? PingTheme.Color.actionPrimary : PingTheme.Color.separator,
                    lineWidth: PingTheme.Shape.borderWidth
                )
        }
    }
}

/// PingExample's namespace for semantic action-button styles.
public extension SwiftUI.ButtonStyle where Self == PingActionButtonStyle {
    /// Applies the dominant Ping primary-action treatment.
    static var pingPrimary: Self { PingActionButtonStyle(role: .primary) }
    /// Applies the lower-emphasis outlined action treatment.
    static var pingSecondary: Self { PingActionButtonStyle(role: .secondary) }
    /// Applies the irreversible/data-removal action treatment.
    static var pingDestructive: Self { PingActionButtonStyle(role: .destructive) }
    /// Applies the confirming/positive-outcome action treatment.
    static var pingAffirmative: Self { PingActionButtonStyle(role: .affirmative) }
}
