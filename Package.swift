// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AsyncStreamed",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "AsyncStreamed",
            targets: ["AsyncStreamed"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-testing", from: "6.0.0" ),
    ],
    targets: [
        .target(
            name: "AsyncStreamed",
            swiftSettings: [
                // .unsafeFlags(["-strict-concurrency=complete"]),
                // .enableUpcomingFeature("StrictConcurrency"),
            ]
        ),
        .testTarget(
            name: "AsyncStreamedTests",
            dependencies: [
                .product(name: "Testing", package: "swift-testing"),
                "AsyncStreamed",
            ],
            swiftSettings: [
                // .unsafeFlags(["-strict-concurrency=complete"]),
                // .enableUpcomingFeature("StrictConcurrency"),
            ]
        ),
    ]
)
