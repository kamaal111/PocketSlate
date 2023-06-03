// swift-tools-version: 5.7
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
        .package(url: "https://github.com/Kamaalio/KamaalSwift.git", "0.6.0" ..< "0.7.0"),
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
