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
        // Здесь будут добавлены зависимости в будущем
        // Например, для работы с сетью, базой данных и т.д.
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