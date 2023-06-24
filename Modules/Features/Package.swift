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
        .package(url: "https://github.com/Kamaalio/KamaalSwift.git", "0.9.2" ..< "0.10.0"),
        .package(url: "https://github.com/kamaal111/ICloutKit.git", "3.0.0" ..< "4.0.0"),
        .package(path: "../AppLocales"),
        .package(path: "../AppUI"),
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
                "ICloutKit",
                "AppLocales",
                "Users",
                "AppUI",
            ]
        ),
        .testTarget(name: "PhrasesTests", dependencies: ["Phrases"]),
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
