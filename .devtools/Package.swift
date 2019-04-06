// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "FinchDevTools",
    dependencies: [
        .package(url: "https://github.com/orta/Komondor.git", from: "1.0.0"),
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.30.1"),
    ],
    targets: [
        .target(
            name: "Fake",
	    path: ".",
            sources: ["blank.swift"]
        )
    ]
)

#if canImport(PackageConfig)
    import PackageConfig

    let config = PackageConfig([
        "komondor": [
            "pre-push": [
                "make lint"
            ]
        ]
    ])
#endif
