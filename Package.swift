// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "Finch",
    products: [
        .executable(name: "Finch", targets: ["Finch"]),
        .library(name: "FinchApp", targets: ["FinchApp"])
    ],
    dependencies: [
        .package(url: "git@github.com:pointfreeco/swift-snapshot-testing", from: "1.1.0"),
        .package(url: "git@github.com:apple/swift-package-manager.git", from: "0.3.0"),
        .package(url: "git@github.com:realm/SwiftLint.git", from: "0.30.1")
    ],
    targets: [
        .target(
            name: "Finch",
            dependencies: ["FinchApp"]),
        .target(
            name: "FinchApp",
            dependencies: ["FinchCore"]),
        .target(
            name: "FinchCore",
            dependencies: ["FinchUtilities"]),
        .target(
            name: "FinchUtilities",
            dependencies: ["Utility"]),
        .testTarget(
            name: "FinchAppTests",
            dependencies: ["FinchApp", "SnapshotTesting"]),
    ]
)
