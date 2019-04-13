// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Finch",
    products: [
        .executable(name: "finch", targets: ["Finch"]),
        .library(name: "FinchApp", targets: ["FinchApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.3.0"),
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
    ],
    swiftLanguageVersions: [.v4, .v4_2, .v5]
)

