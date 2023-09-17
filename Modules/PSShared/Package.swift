// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PSShared",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(
            name: "PSShared",
            targets: ["PSShared"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Kamaalio/KamaalSwift.git", .upToNextMajor(from: "1.2.0")),
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
