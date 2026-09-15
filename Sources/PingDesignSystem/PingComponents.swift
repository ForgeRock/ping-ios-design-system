//
//  PingComponents
//  PingDesignSystem
//
//  Copyright (c) 2025 - 2026 Ping Identity Corporation. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//


import SwiftUI

// MARK: - Repeated components

/// Displays validation messages beneath an app-owned input.
///
/// Each non-empty message is rendered in the semantic error color; empty
/// entries are silently dropped. The caller owns validation, localization,
/// ordering, and sanitization of all supplied messages.
public struct PingFieldMessages: View {
    /// Ordered validation messages displayed using the semantic error color.
    public var errorMessages: [String] = []

    public init(errorMessages: [String] = []) {
        self.errorMessages = errorMessages
    }

    public var body: some View {
        let messages = errorMessages.filter { !$0.isEmpty }

        return VStack(alignment: .leading, spacing: PingTheme.Spacing.xSmall) {
            ForEach(Array(messages.enumerated()), id: \.offset) { _, message in
                Text(message)
                    .font(PingTheme.Typography.supporting)
                    .foregroundStyle(PingTheme.Color.statusError)
            }
        }
    }
}

/// A password input with shared visibility-toggle and validation behavior.
///
/// The caller owns the text binding, validation calculation, and localized
/// error messages. When `isVisible` is `false`, this component uses a secure
/// entry control; when `true`, it shows the editable text. The field content is
/// marked privacy-sensitive so it is redacted from app-switcher snapshots and
/// screen captures while shown as plain text. The toggle retains a 44-point
/// target and exposes an explicit VoiceOver label.
public struct PingSecureField: View {
    /// The visible label and accessibility label for the password field.
    public let label: String
    /// The password value owned by the caller.
    @Binding var text: String
    /// Controls whether the password is shown as plain text.
    @Binding var isVisible: Bool
    /// Ordered validation messages controlling the error border and message area.
    public var errorMessages: [String] = []
    /// Called when the underlying field submits.
    public var onSubmit: () -> Void = {}

    public init(
        label: String,
        text: Binding<String>,
        isVisible: Binding<Bool>,
        errorMessages: [String] = [],
        onSubmit: @escaping () -> Void = {}
    ) {
        self.label = label
        self._text = text
        self._isVisible = isVisible
        self.errorMessages = errorMessages
        self.onSubmit = onSubmit
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: PingTheme.Spacing.small) {
            Text(label)
                .pingSectionHeader()

            HStack(spacing: PingTheme.Spacing.small) {
                Group {
                    if isVisible {
                        TextField(label, text: $text)
                    } else {
                        SecureField(label, text: $text)
                    }
                }
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .privacySensitive()
                .onSubmit(onSubmit)

                Button {
                    isVisible.toggle()
                } label: {
                    Image(systemName: isVisible ? "eye.slash" : "eye")
                        .foregroundStyle(PingTheme.Color.actionPrimary)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .accessibilityLabel(isVisible ? "Hide password" : "Show password")
            }
            .padding(.leading, PingTheme.Control.fieldPadding)
            .padding(.trailing, PingTheme.Spacing.xSmall)
            .background(PingTheme.Color.inputSurface)
            .clipShape(RoundedRectangle(cornerRadius: PingTheme.Shape.fieldRadius))
            .overlay(
                RoundedRectangle(cornerRadius: PingTheme.Shape.fieldRadius)
                    .stroke(
                        errorMessages.isEmpty ? PingTheme.Color.separator : PingTheme.Color.statusError,
                        lineWidth: PingTheme.Shape.borderWidth
                    )
            )

            PingFieldMessages(errorMessages: errorMessages)
        }
    }
}

/// Renders a semantic system-image icon inside a Ping-branded tile or
/// circular avatar.
///
/// The surface and icon tint use ``PingTheme/Color/actionPrimary`` and
/// ``PingTheme/Color/actionPrimaryForeground`` — the same dynamic pairing
/// ``PingActionButtonStyle`` uses for its primary role — so contrast stays
/// correct in dark appearance. Earlier ad hoc call sites paired a
/// fixed-color gradient with a literal white icon, which lost contrast in
/// dark mode; this component avoids that by construction.
public struct PingIconTile: View {
    /// The tile's clip shape.
    public enum TileShape {
        case roundedRect
        case circle
    }

    public let systemName: String
    public var diameter: CGFloat = 40
    public var cornerRadius: CGFloat = PingTheme.Shape.tileRadius
    public var iconSize: CGFloat = 20
    public var shape: TileShape = .roundedRect
    /// Overlays a small lock badge in the bottom-trailing corner, for a
    /// locked/blocked credential.
    public var isLocked: Bool = false

    public init(systemName: String, diameter: CGFloat = 40, cornerRadius: CGFloat = PingTheme.Shape.tileRadius, iconSize: CGFloat = 20, shape: TileShape = .roundedRect, isLocked: Bool = false) {
        self.systemName = systemName
        self.diameter = diameter
        self.cornerRadius = cornerRadius
        self.iconSize = iconSize
        self.shape = shape
        self.isLocked = isLocked
    }

    public var body: some View {
        let icon = Image(systemName: systemName)
            .font(.system(size: iconSize))
            .foregroundStyle(PingTheme.Color.actionPrimaryForeground)
            .frame(width: diameter, height: diameter)
            .background(PingTheme.Color.actionPrimary)

        let tile: AnyView
        switch shape {
        case .roundedRect:
            tile = AnyView(icon.clipShape(RoundedRectangle(cornerRadius: cornerRadius)))
        case .circle:
            tile = AnyView(icon.clipShape(Circle()))
        }

        return ZStack(alignment: .bottomTrailing) {
            tile

            if isLocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.white)
                    .padding(3)
                    .background(PingTheme.Color.statusError)
                    .clipShape(Circle())
                    .offset(x: 4, y: 4)
            }
        }
    }
}

/// Displays a circular determinate progress ring.
///
/// Replaces ad hoc circular progress drawing. Pass
/// ``PingTheme/Color/statusError`` as `tint` to represent a locked/blocked
/// state instead of hardcoding a reduced-opacity red.
public struct PingProgressRing: View {
    /// Fractional completion, `0...1`.
    public let progress: Double
    public var lineWidth: CGFloat = 3
    public var diameter: CGFloat = 40
    public var tint: SwiftUI.Color = PingTheme.Color.actionPrimary

    public init(progress: Double, lineWidth: CGFloat = 3, diameter: CGFloat = 80, tint: SwiftUI.Color = PingTheme.Color.actionPrimary) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.diameter = diameter
        self.tint = tint
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(PingTheme.Color.separator, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: diameter, height: diameter)
    }
}

/// Displays a label/value pair for read-only account or device metadata.
public struct PingInfoRow: View {
    public enum RowLayout {
        case horizontal
        case vertical
    }
    public enum ValueStyle {
        case body
        case monospaced
    }

    public let label: String
    public let value: String
    public var layout: RowLayout = .horizontal
    public var valueStyle: ValueStyle = .body
    /// Optional fixed label width for aligned columns of rows.
    public var labelWidth: CGFloat?

    public init(label: String, value: String, layout: RowLayout = .horizontal, valueStyle: ValueStyle = .body, labelWidth: CGFloat? = nil) {
        self.label = label
        self.value = value
        self.layout = layout
        self.valueStyle = valueStyle
        self.labelWidth = labelWidth
    }

    public var body: some View {
        switch layout {
        case .horizontal:
            HStack(alignment: .top, spacing: PingTheme.Spacing.small) {
                labelText
                valueText
            }
        case .vertical:
            VStack(alignment: .leading, spacing: PingTheme.Spacing.xSmall) {
                labelText
                valueText
            }
        }
    }

    private var labelText: some View {
        Text(label)
            .font(PingTheme.Typography.caption)
            .foregroundStyle(PingTheme.Color.contentSecondary)
            .frame(width: labelWidth, alignment: .leading)
    }

    private var valueText: some View {
        Text(value)
            .font(valueStyle == .monospaced ? PingTheme.Typography.monospacedCaption : PingTheme.Typography.caption)
            .foregroundStyle(PingTheme.Color.contentPrimary)
    }
}

/// A full-screen dimmed scrim with a centered progress indicator.
///
/// Place inside a `ZStack`, conditionally, over the content being loaded.
public struct PingLoadingOverlay: View {
    public init() {
    }

    public var body: some View {
        SwiftUI.Color.black.opacity(0.4)
            .ignoresSafeArea()
            .overlay(
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: PingTheme.Color.contentInverse))
                    .scaleEffect(2)
            )
    }
}

/// The app's large in-content loading spinner, replacing ad hoc
/// `ProgressView` + `progressViewStyle` + `scaleEffect` boilerplate. Unlike
/// ``PingLoadingOverlay``, this has no dimming backdrop — use it inline
/// (e.g. centered in an empty screen or list) rather than over existing
/// content the user shouldn't interact with.
public struct PingLoadingSpinner: View {
    public var tint: SwiftUI.Color = PingTheme.Color.actionPrimary

    public init(tint: SwiftUI.Color = PingTheme.Color.actionPrimary) {
        self.tint = tint
    }

    public var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: tint))
            .scaleEffect(1.5)
    }
}

/// An outlined circular button labeled with a single number, used for
/// MFA/DaVinci number-selection challenges.
public struct PingChallengeNumberButton: View {
    public let number: Int
    public var diameter: CGFloat = 80
    public let action: () -> Void

    public init(number: Int, diameter: CGFloat = 80, action: @escaping () -> Void) {
        self.number = number
        self.diameter = diameter
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text("\(number)")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(PingTheme.Color.actionPrimary)
                .frame(width: diameter, height: diameter)
                .overlay(
                    Circle().stroke(PingTheme.Color.actionPrimary, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }
}

/// A small filled circular badge showing a step number, for numbered
/// instructional callouts.
public struct PingStepBadge: View {
    public let number: Int
    public var diameter: CGFloat = 22

    public init(number: Int, diameter: CGFloat = 22) {
        self.number = number
        self.diameter = diameter
    }

    public var body: some View {
        Text("\(number)")
            .font(.system(size: 13, weight: .bold, design: .monospaced))
            .foregroundStyle(PingTheme.Color.actionPrimaryForeground)
            .frame(width: diameter, height: diameter)
            .background(PingTheme.Color.actionPrimary)
            .clipShape(Circle())
    }
}
