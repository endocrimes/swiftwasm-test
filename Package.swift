// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swiftwasm-test",
  platforms: [
    .macOS(.v11),
    .iOS(.v13),
    .tvOS(.v13),
    .watchOS(.v8),
    .driverKit(.v21),
    .macCatalyst(.v13),
  ],
  products: [
    .library(name: "Spin", targets: ["Spin"])
  ],
  dependencies: [
    .package(url: "https://github.com/vapor/routing-kit.git", from: "4.6.0")
  ],
  targets: [
    .target(name: "CSpinConfig", dependencies: []),
    .target(name: "CSpinHTTP", dependencies: []),
    .target(
      name: "Spin",
      dependencies: [
        "CSpinHTTP",
        "CSpinConfig",
        .product(name: "RoutingKit", package: "routing-kit"),
      ]),
    .executableTarget(
      name: "swiftwasm-test",
      dependencies: [
        "Spin"
      ]),
    .testTarget(
      name: "SpinTests",
      dependencies: ["Spin"]),
  ]
)
