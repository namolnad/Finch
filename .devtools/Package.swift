// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "FinchDevTools",
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.38.0")
    ],
    targets: [
        .target(name: "FinchDevTools", path: ".", sources: ["Tools.swift"])
    ]
)

