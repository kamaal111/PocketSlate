// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CDPersist",
    platforms: [.macOS(.v12), .iOS(.v15)],
    products: [
        .library(
            name: "CDPersist",
            targets: ["CDPersist"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Kamaalio/KamaalSwift.git", "0.8.1" ..< "0.9.0"),
        .package(path: "../Models"),
    ],
    targets: [
        .target(
            name: "CDPersist",
            dependencies: [
                .product(name: "KamaalExtensions", package: "KamaalSwift"),
                .product(name: "KamaalCoreData", package: "KamaalSwift"),
                "Models",
            ]
        ),
        .testTarget(
            name: "CDPersistTests",
            dependencies: ["CDPersist"]
        ),
    ]
)
