// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PSShared",
    platforms: [.macOS(.v12), .iOS(.v15), .watchOS(.v7)],
    products: [
        .library(
            name: "PSShared",
            targets: ["PSShared"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Kamaalio/KamaalSwift.git", .upToNextMinor(from: "0.9.2")),
    ],
    targets: [
        .target(
            name: "PSShared",
            dependencies: [
                .product(name: "KamaalLogger", package: "KamaalSwift"),
            ]
        ),
        .testTarget(
            name: "PSSharedTests",
            dependencies: ["PSShared"]
        ),
    ]
)
