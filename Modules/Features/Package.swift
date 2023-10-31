// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Features",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(name: "CloudSyncing", targets: ["CloudSyncing"]),
        .library(name: "PhrasesV2", targets: ["PhrasesV2"]),
        .library(name: "Persistance", targets: ["Persistance"]),
        .library(name: "Users", targets: ["Users"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Kamaalio/KamaalSwift.git", .upToNextMajor(from: "1.2.0")),
        .package(url: "https://github.com/apple/swift-algorithms.git", .upToNextMajor(from: "1.0.0")),
        .package(path: "../AppLocales"),
        .package(path: "../AppUI"),
        .package(path: "../PocketSlateAPI"),
        .package(path: "../Models"),
        .package(path: "../PSShared"),
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
        .target(name: "PhrasesV2", dependencies: [
            .product(name: "KamaalUI", package: "KamaalSwift"),
            .product(name: "KamaalUtils", package: "KamaalSwift"),
            .product(name: "KamaalExtensions", package: "KamaalSwift"),
            .product(name: "KamaalLogger", package: "KamaalSwift"),
            .product(name: "KamaalAlgorithms", package: "KamaalSwift"),
            .product(name: "Algorithms", package: "swift-algorithms"),
            "AppUI",
            "Users",
            "Persistance",
            "PocketSlateAPI",
            "Models",
            "PSShared",
        ],
        resources: [
            .process("Internals/Resources"),
        ]),
        .testTarget(name: "PhrasesV2Tests", dependencies: ["PhrasesV2"]),
        .target(name: "Persistance", dependencies: [
            .product(name: "KamaalExtensions", package: "KamaalSwift"),
            "Models",
        ]),
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
