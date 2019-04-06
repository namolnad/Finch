// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "FinchDevTools",
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.30.1")
    ],
    targets: [
        .target(
            name: "Fake",
	    path: ".",
            sources: ["blank.swift"]
        )
    ]
)

