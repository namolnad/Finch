// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DiffFormatter",
    products: [
        .executable(name: "DiffFormatter", targets: ["DiffFormatter"]),
        .library(name: "DiffFormatterApp", targets: ["DiffFormatterApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "DiffFormatter",
            dependencies: ["DiffFormatterApp"]),
        .target(
            name: "DiffFormatterApp",
            dependencies: ["DiffFormatterCore", "DiffFormatterRouting", "DiffFormatterTelemetry", "DiffFormatterUtilities"]),
        .target(
            name: "DiffFormatterCore",
            dependencies: ["DiffFormatterUtilities"]),
        .target(
            name: "DiffFormatterRouting",
            dependencies: ["DiffFormatterCore", "DiffFormatterUtilities"]),
        .target(
            name: "DiffFormatterTelemetry",
            dependencies: []),
        .target(
            name: "DiffFormatterUtilities",
            dependencies: []),
        .testTarget(
            name: "DiffFormatterAppTests",
            dependencies: ["DiffFormatterApp", "SnapshotTesting"]),
    ]
)
