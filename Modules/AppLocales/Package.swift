// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppLocales",
    defaultLocalization: "en",
    products: [
        .library(
            name: "AppLocales",
            targets: ["AppLocales"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AppLocales",
            dependencies: [],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "AppLocalesTests",
            dependencies: ["AppLocales"]
        ),
    ]
)
