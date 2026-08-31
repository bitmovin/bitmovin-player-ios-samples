// swift-tools-version: 5.9

import PackageDescription

// Google does not provide a usable official Swift package for the Cast iOS SDK yet,
// so this proxy exposes the manually distributed XCFramework through Swift Package Manager.
// TODO: Replace this proxy with https://github.com/googlecast/google-cast-ios-sdk
// once Google publishes a Package.swift and tagged release.
let package = Package(
    name: "GoogleCastSPMProxy",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "GoogleCast",
            targets: ["GoogleCast"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "GoogleCast",
            url: "https://dl.google.com/dl/chromecast/sdk/ios/GoogleCastSDK-ios-4.8.6_dynamic.zip",
            checksum: "55f6c21291a1315c68063f07e7d76225564bff70f2fd38caad135c71d66eb310"
        ),
    ]
)
