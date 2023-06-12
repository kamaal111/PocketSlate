// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Features",
    platforms: [.macOS(.v12), .iOS(.v15)],
    products: [
        .library(
            name: "Phrases",
            targets: ["Phrases"]
        ),
        .library(
            name: "Users",
            targets: ["Users"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Kamaalio/KamaalSwift.git", "0.8.1" ..< "0.9.0"),
        .package(path: "../AppLocales"),
    ],
    targets: [
        .target(
            name: "Phrases",
            dependencies: [
                .product(name: "KamaalPopUp", package: "KamaalSwift"),
                .product(name: "KamaalExtensions", package: "KamaalSwift"),
                .product(name: "KamaalUtils", package: "KamaalSwift"),
                .product(name: "KamaalLogger", package: "KamaalSwift"),
                .product(name: "KamaalUI", package: "KamaalSwift"),
                .product(name: "KamaalAlgorithms", package: "KamaalSwift"),
                "AppLocales",
                "Users",
            ]
        ),
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
