// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PingDesignSystem",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // The shared Ping-branded SwiftUI design system: semantic tokens
        // (PingTheme), view modifiers, text roles, components, and button styles.
        .library(
            name: "PingDesignSystem",
            targets: ["PingDesignSystem"]),
    ],
    targets: [
        .target(
            name: "PingDesignSystem"),
    ]
)
