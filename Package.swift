// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "DiffFormatter",
    products: [
        .executable(name: "DiffFormatter", targets: ["DiffFormatter"]),
        .library(name: "DiffFormatterApp", targets: ["DiffFormatterApp"])
    ],
    dependencies: [
        .package(url: "git@github.com:pointfreeco/swift-snapshot-testing", from: "1.1.0"),
        .package(url: "git@github.com:apple/swift-package-manager.git", from: "0.3.0"),
        .package(url: "git@github.com:realm/SwiftLint.git", from: "0.30.1")
    ],
    targets: [
        .target(
            name: "DiffFormatter",
            dependencies: ["DiffFormatterApp"]),
        .target(
            name: "DiffFormatterApp",
            dependencies: ["DiffFormatterCore", "Utility"]),
        .target(
            name: "DiffFormatterCore",
            dependencies: ["DiffFormatterUtilities"]),
        .target(
            name: "DiffFormatterUtilities",
            dependencies: []),
        .testTarget(
            name: "DiffFormatterAppTests",
            dependencies: ["DiffFormatterApp", "SnapshotTesting"]),
    ]
)
