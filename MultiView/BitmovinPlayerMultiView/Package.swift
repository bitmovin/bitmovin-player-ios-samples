// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MultiViewPlayer",
    platforms: [
        .iOS(.v14), .tvOS(.v17), .visionOS(.v1)
    ],
    products: [
        .library(
            name: "BitmovinPlayerMultiView",
            targets: ["BitmovinPlayerMultiView"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/bitmovin/player-ios-core.git", .upToNextMajor(from: "3.0.0")),
    ],
    targets: [
        .target(
            name: "BitmovinPlayerMultiView",
            dependencies: [
                .product(name: "BitmovinPlayerCore", package: "player-ios-core"),
            ]
        ),
    ]
)
