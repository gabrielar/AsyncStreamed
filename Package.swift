// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription


private let testingPackageDependencies: [PackageDescription.Package.Dependency]
private let testingTargetDepencencies: [PackageDescription.Target.Dependency]
#if os(Linux)
testingPackageDependencies = [.package(url: "https://github.com/swiftlang/swift-testing", from: "6.0.0" )]
testingTargetDepencencies = [.product(name: "Testing", package: "swift-testing")]
#else
testingPackageDependencies = []
testingTargetDepencencies = []
#endif

let package = Package(
    name: "AsyncStreamed",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "AsyncStreamed",
            targets: ["AsyncStreamed"]),
    ],
    dependencies: [] + testingPackageDependencies,
    targets: [
        .target(
            name: "AsyncStreamed",
            swiftSettings: []
        ),
        .testTarget(
            name: "AsyncStreamedTests",
            dependencies: [
                "AsyncStreamed",
            ] + testingTargetDepencencies,
            swiftSettings: []
        ),
    ]
)
