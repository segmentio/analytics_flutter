// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "segment_analytics_plugin_idfa",
    platforms: [
        .iOS("13.0"),
    ],
    products: [
        .library(name: "segment-analytics-plugin-idfa", targets: ["segment_analytics_plugin_idfa"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
    ],
    targets: [
        .target(
            name: "segment_analytics_plugin_idfa",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
            ],
            linkerSettings: [
                .linkedFramework("AdSupport"),
                .linkedFramework("AppTrackingTransparency"),
            ]
        ),
    ]
)
