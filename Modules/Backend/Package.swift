// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Backend",
    platforms: [.macOS(.v12), .iOS(.v15)],
    products: [
        .library(
            name: "Backend",
            targets: ["Backend"]
        ),
    ],
    dependencies: [
        .package(path: "../Models"),
    ],
    targets: [
        .target(
            name: "Backend",
            dependencies: [
                "Models",
            ]
        ),
        .testTarget(
            name: "BackendTests",
            dependencies: ["Backend"]
        ),
    ]
)
