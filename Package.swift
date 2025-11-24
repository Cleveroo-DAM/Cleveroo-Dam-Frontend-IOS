// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CleverooDAM",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "CleverooDAM",
            targets: ["CleverooDAM"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CleverooDAM",
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "CleverooDAMTests",
            dependencies: ["CleverooDAM"],
            path: "Tests"),
    ]
)
