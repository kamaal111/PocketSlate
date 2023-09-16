// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Features",
    platforms: [.macOS(.v12), .iOS(.v15)],
    products: [
        .library(name: "CloudSyncing", targets: ["CloudSyncing"]),
        .library(name: "PhrasesV1", targets: ["PhrasesV1"]),
        .library(name: "Users", targets: ["Users"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Kamaalio/KamaalSwift.git", .upToNextMajor(from: "1.2.0")),
        .package(path: "../AppLocales"),
        .package(path: "../AppUI"),
        .package(path: "../PocketSlateAPI"),
    ],
    targets: [
        .target(
            name: "CloudSyncing",
            dependencies: [
                .product(name: "KamaalLogger", package: "KamaalSwift"),
                .product(name: "KamaalExtensions", package: "KamaalSwift"),
                .product(name: "KamaalCloud", package: "KamaalSwift"),
            ]
        ),
        .target(
            name: "PhrasesV1",
            dependencies: [
                .product(name: "KamaalPopUp", package: "KamaalSwift"),
                .product(name: "KamaalExtensions", package: "KamaalSwift"),
                .product(name: "KamaalUtils", package: "KamaalSwift"),
                .product(name: "KamaalLogger", package: "KamaalSwift"),
                .product(name: "KamaalUI", package: "KamaalSwift"),
                .product(name: "KamaalAlgorithms", package: "KamaalSwift"),
                "AppLocales",
                "Users",
                "AppUI",
                "CloudSyncing",
                "PocketSlateAPI",
            ],
            resources: [
                .process("Internals/Resources"),
            ]
        ),
        .testTarget(name: "PhrasesV1Tests", dependencies: ["PhrasesV1"]),
        .target(
            name: "Users",
            dependencies: [
                .product(name: "KamaalLogger", package: "KamaalSwift"),
                .product(name: "KamaalSettings", package: "KamaalSwift"),
                .product(name: "KamaalExtensions", package: "KamaalSwift"),
                .product(name: "KamaalUtils", package: "KamaalSwift"),
                "AppLocales",
            ],
            resources: [
                .process("Internals/Resources"),
            ]
        ),
    ]
)
