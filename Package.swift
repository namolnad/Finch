// swift-tools-version:6.0

import Foundation
import PackageDescription

var dependencies: [Package.Dependency] = [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.8.0"),
    .package(url: "https://github.com/jpsim/Yams.git", from: "6.2.2"),
    .package(url: "https://github.com/mxcl/Version.git", from: "2.0.0")
]

var targets: [Target] = [
    .executableTarget(
        name: "Finch",
        dependencies: ["FinchApp"]
    ),
    .target(
        name: "FinchApp",
        dependencies: [
            "FinchCore",
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "Version", package: "Version")
        ]
    ),
    .target(
        name: "FinchCore",
        dependencies: ["FinchUtilities"]
    ),
    .target(
        name: "FinchUtilities",
        dependencies: [
            .product(name: "Yams", package: "Yams")
        ]
    )
]

/*
 * The test target and its dependencies are opt-in so that installs — `mint`,
 * `brew`, `make install` — resolve neither swift-snapshot-testing nor the
 * swift-syntax tree beneath it. Every make target which touches the package
 * pins resolution to Package.resolved, so building with and without this set
 * cannot rewrite the file out from under each other.
 */
if ProcessInfo.processInfo.environment["FINCH_TESTS"] != nil {
    targets.append(
        .testTarget(
            name: "FinchAppTests",
            dependencies: [
                "FinchApp",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "Yams", package: "Yams")
            ],
            path: "Tests",
            // Snapshots are read from source by SnapshotTesting, not from the bundle
            exclude: ["FinchAppTests/__Snapshots__"],
            resources: [
                .process("FinchAppTests/Resources")
            ]
        )
    )
    dependencies.append(
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.8.2")
    )
}

let package = Package(
    name: "Finch",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "finch", targets: ["Finch"])
    ],
    dependencies: dependencies,
    targets: targets
)
