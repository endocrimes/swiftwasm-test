// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swiftwasm-test",
  dependencies: [
    //        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
  ],
  targets: [
    .target(name: "CSpinConfig", dependencies: []),
    .target(name: "CSpinHTTP", dependencies: []),
    .target(
      name: "SpinHTTP",
      dependencies: [
        "CSpinHTTP"
      ]),
    .target(
      name: "SpinConfig",
      dependencies: [
        "CSpinConfig"
      ]),
    .executableTarget(
      name: "swiftwasm-test",
      dependencies: [
        "SpinConfig",
        "SpinHTTP",
        //                .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]),
    .testTarget(
      name: "swiftwasm-testTests",
      dependencies: ["swiftwasm-test"]),
  ]
)
