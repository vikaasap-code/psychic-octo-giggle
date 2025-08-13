// swift-tools-version: 5.8
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
        .package(url: "https://github.com/SwiftUIX/SwiftUIX.git", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "AstroMatch",
            dependencies: ["SwiftUIX"],
            path: "Sources"),
        .testTarget(
            name: "AstroMatchTests",
            dependencies: ["AstroMatch"],
            path: "Tests"),
    ]
)