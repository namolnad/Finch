// swift-tools-version:4.2

import PackageDescription

var dependencies: [Package.Dependency] = [
        .package(url: "https://github.com/Carthage/Commandant.git", from: "0.16.0"),
        .package(url: "https://github.com/thoughtbot/Curry.git", from: "4.0.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0"),
        .package(url: "https://github.com/mxcl/Version.git", from: "1.0.0")
]

var finchDependencies: [Target.Dependency] = ["FinchCore", "Commandant", "Curry", "Version"]

#if swift(>=5.0)
dependencies.append(.package(url: "https://github.com/antitypical/Result.git", from:"4.1.0"))
finchDependencies.append("Result")
#endif

let package = Package(
    name: "Finch",
    products: [
        .executable(name: "finch", targets: ["Finch"]),
        .library(name: "FinchApp", targets: ["FinchApp"])
    ],
    dependencies: dependencies,
    targets: [
        .target(
            name: "Finch",
            dependencies: ["FinchApp"]),
        .target(
            name: "FinchApp",
            dependencies: finchDependencies),
        .target(
            name: "FinchCore",
            dependencies: ["FinchUtilities"]),
        .target(
            name: "FinchUtilities",
            dependencies: ["Yams"])
    ],
    swiftLanguageVersions: [.v4, .v4_2, .version("5")]
)
