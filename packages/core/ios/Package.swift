// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "segment_analytics",
    platforms: [
        .iOS("12.0"),
    ],
    products: [
        .library(name: "segment-analytics", type: .static, targets: ["segment_analytics"]),
    ],
    targets: [
        .target(
            name: "segment_analytics",
            dependencies: [],
            path: "Classes",
            linkerSettings: [
                .linkedFramework("Flutter", .when(platforms: [.iOS])),
            ]
        ),
    ]
)
