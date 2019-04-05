// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "Finch",
    products: [
        .executable(name: "finch", targets: ["Finch"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.3.0"),
        .package(url: "https://github.com/orta/Komondor.git", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.1.0"),
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.30.1"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "1.0.1"),
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
            dependencies: ["Utility", "Yams"]),
        .testTarget(
            name: "FinchAppTests",
            dependencies: ["FinchApp", "SnapshotTesting", "Yams"]),
    ]
)

#if canImport(PackageConfig)
    import PackageConfig

    let config = PackageConfig([
        "komondor": [
            "pre-push": [
                "make lint",
            ],
        ],
    ])
#endif
