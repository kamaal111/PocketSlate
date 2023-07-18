// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PocketSlateAPI",
    platforms: [.macOS(.v12), .iOS(.v15), .watchOS(.v7)],
    products: [
        .library(
            name: "PocketSlateAPI",
            targets: ["PocketSlateAPI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", .upToNextMinor(from: "0.1.4")),
        .package(url: "https://github.com/apple/swift-openapi-runtime", .upToNextMinor(from: "0.1.0")),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", .upToNextMinor(from: "0.1.0")),
        .package(url: "https://github.com/Kamaalio/KamaalSwift.git", .upToNextMinor(from: "0.9.2")),
        .package(path: "../AppLocales"),
    ],
    targets: [
        .target(
            name: "PocketSlateAPI",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
                .product(name: "KamaalExtensions", package: "KamaalSwift"),
                "AppLocales",
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
