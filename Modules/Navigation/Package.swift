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
        .package(url: "https://github.com/Kamaalio/KamaalSwift.git", "0.8.1" ..< "0.9.0"),
        .package(path: "../AppLocales"),
    ],
    targets: [
        .target(
            name: "Navigation",
            dependencies: [
                .product(name: "KamaalNavigation", package: "KamaalSwift"),
                "AppLocales",
            ]
        ),
    ]
)
