// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Navigation",
    platforms: [.macOS(.v12), .iOS(.v15)],
    products: [
        .library(
            name: "Navigation",
            targets: ["Navigation"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Kamaalio/KamaalSwift.git", .upToNextMajor(from: "1.2.0")),
        .package(path: "../AppLocales"),
        .package(path: "../Features"),
    ],
    targets: [
        .target(
            name: "Navigation",
            dependencies: [
                .product(name: "KamaalNavigation", package: "KamaalSwift"),
                .product(name: "KamaalUI", package: "KamaalSwift"),
                .product(name: "KamaalPopUp", package: "KamaalSwift"),
                .product(name: "KamaalSettings", package: "KamaalSwift"),
                .product(name: "Users", package: "Features"),
                .product(name: "PhrasesV1", package: "Features"),
                "AppLocales",
            ]
        ),
    ]
)
