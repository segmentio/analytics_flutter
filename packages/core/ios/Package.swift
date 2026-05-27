// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "segment_analytics",
    platforms: [
        .iOS("12.0"),
    ],
    products: [
        .library(name: "segment_analytics", targets: ["segment_analytics"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "segment_analytics",
            dependencies: [],
            path: "Classes"
        ),
    ]
)