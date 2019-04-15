// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "FinchTests",
    dependencies: [
        // Refer to local Finch package via path
        .package(path: "../"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.1.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0")
    ],
    targets: [
        .testTarget(
            name: "FinchAppTests",
            dependencies: ["FinchApp", "SnapshotTesting", "Yams"],
            path: "FinchAppTests"
        )
    ]
)

