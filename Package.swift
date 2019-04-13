// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "Finch",
    products: [
        .executable(name: "finch", targets: ["Finch"]),
        .library(name: "FinchApp", targets: ["FinchApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/Carthage/Commandant.git", from: "0.17.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "1.0.1"),
        .package(url: "https://github.com/mxcl/Version.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Finch",
            dependencies: ["FinchApp"]),
        .target(
            name: "FinchApp",
            dependencies: ["FinchCore", "Commandant", "Version"]),
        .target(
            name: "FinchCore",
            dependencies: ["FinchUtilities"]),
        .target(
            name: "FinchUtilities",
            dependencies: ["Yams"]),
    ]
)

