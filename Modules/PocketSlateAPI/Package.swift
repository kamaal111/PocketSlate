// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PocketSlateAPI",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(
            name: "PocketSlateAPI",
            targets: ["PocketSlateAPI"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/Kamaalio/swift-openapi-generator",
            revision: "dd9526dcc64049df10cfb4a343ed5ee60a675e04"
        ),
        .package(url: "https://github.com/apple/swift-openapi-runtime", .upToNextMinor(from: "0.2.2")),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", .upToNextMinor(from: "0.2.2")),
        .package(url: "https://github.com/Kamaalio/KamaalSwift.git", .upToNextMajor(from: "1.2.0")),
        .package(path: "../AppLocales"),
        .package(path: "../PSShared"),
    ],
    targets: [
        .target(
            name: "PocketSlateAPI",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
                .product(name: "KamaalExtensions", package: "KamaalSwift"),
                .product(name: "KamaalLogger", package: "KamaalSwift"),
                "AppLocales",
                "PSShared",
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
            ]
        ),
        .testTarget(
            name: "PocketSlateAPITests",
            dependencies: ["PocketSlateAPI"]
        ),
    ]
)
