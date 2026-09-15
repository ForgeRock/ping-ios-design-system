//
//  TabPicker.swift
//  PingDesignSystem
//
//  Copyright (c) 2026 Ping Identity Corporation. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//


import SwiftUI

/// A reusable horizontal pill-style tab picker.
/// Generic over any tab type that conforms to `Hashable`, `CaseIterable`, and `Identifiable`.
public struct TabPicker<Tab: Hashable & CaseIterable & Identifiable>: View
where Tab.AllCases: RandomAccessCollection {
    @Binding var selection: Tab
    let label: (Tab) -> String
    let icon: (Tab) -> String
    var onSelect: ((Tab) -> Void)? = nil
    var isDisabled: Bool = false

    public init(
        selection: Binding<Tab>,
        label: @escaping (Tab) -> String,
        icon: @escaping (Tab) -> String,
        onSelect: ((Tab) -> Void)? = nil,
        isDisabled: Bool = false
    ) {
        self._selection = selection
        self.label = label
        self.icon = icon
        self.onSelect = onSelect
        self.isDisabled = isDisabled
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PingTheme.Spacing.medium) {
                ForEach(Tab.allCases) { tab in
                    tabButton(tab)
                }
            }
            .padding(.horizontal, PingTheme.Spacing.screen)
            .padding(.vertical, PingTheme.Spacing.medium)
        }
        .background(PingTheme.Color.groupedSurface)
    }

    private func tabButton(_ tab: Tab) -> some View {
        Button {
            selection = tab
            onSelect?(tab)
        } label: {
            HStack(spacing: PingTheme.Spacing.small) {
                Image(systemName: icon(tab))
                    .font(.system(size: 14))
                Text(label(tab))
                    .font(PingTheme.Typography.supporting.weight(.medium))
            }
            .padding(.horizontal, PingTheme.Spacing.medium)
            .padding(.vertical, PingTheme.Spacing.small)
            .background(
                selection == tab
                    ? PingTheme.Color.actionPrimary
                    : PingTheme.Color.groupedSurface
            )
            .foregroundStyle(selection == tab ? PingTheme.Color.actionPrimaryForeground : PingTheme.Color.contentSecondary)
            .clipShape(RoundedRectangle(cornerRadius: PingTheme.Shape.pillRadius))
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}
