// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PocketSlateAPI",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(
            name: "PocketSlateAPI",
            targets: ["PocketSlateAPI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", .upToNextMinor(from: "0.1.0")),
        .package(url: "https://github.com/apple/swift-openapi-runtime", .upToNextMinor(from: "0.1.0")),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", .upToNextMinor(from: "0.1.0")),
    ],
    targets: [
        .target(
            name: "PocketSlateAPI",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
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
