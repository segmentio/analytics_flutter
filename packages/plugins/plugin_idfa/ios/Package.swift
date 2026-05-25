// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "segment_analytics_plugin_idfa",
    platforms: [
        .iOS("12.0"),
    ],
    products: [
        .library(name: "segment-analytics-plugin-idfa", type: .static, targets: ["segment_analytics_plugin_idfa"])
    ],
    targets: [
        .target(
            name: "segment_analytics_plugin_idfa",
            dependencies: [],
            path: "Classes",
            linkerSettings: [
                .linkedFramework("Flutter", .when(platforms: [.iOS])),
                .linkedFramework("AdSupport", .when(platforms: [.iOS])),
                .linkedFramework("AppTrackingTransparency", .when(platforms: [.iOS])),
            ]
        )
    ]
)
