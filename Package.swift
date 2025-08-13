// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AstroMatch",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "AstroMatch",
            targets: ["AstroMatch"]),
    ],
    dependencies: [
        // Здесь можно добавить внешние зависимости в будущем
        // Например:
        // .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),
    ],
    targets: [
        .target(
            name: "AstroMatch",
            dependencies: []),
        .testTarget(
            name: "AstroMatchTests",
            dependencies: ["AstroMatch"]),
    ]
)