// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swiftwasm-test",
    dependencies: [
//        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "swiftwasm-test",
            dependencies: [
//                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .testTarget(
            name: "swiftwasm-testTests",
            dependencies: ["swiftwasm-test"]),
    ]
)
