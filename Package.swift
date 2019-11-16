// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AirBar",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "AirBar",
            targets: ["AirBar"]),
    ],
    targets: [
        .target(
            name: "AirBar",
            path: "AirBar"
        ),
        .testTarget(
            name: "AirBarTests",
            dependencies: ["AirBar"],
            path: "AirBarTests"
        ),
    ]
)
