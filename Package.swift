// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Bencode",
    platforms: [
        // Add support for all platforms starting from a specific version.
        .macOS(.v10_10),
        .iOS(.v9),
        .watchOS(.v2),
        .tvOS(.v9)
    ],
    products: [
        .library(name: "Bencode", targets: ["Bencode"])
    ],
    targets: [
        .target(name: "Bencode", dependencies: [])
    ]
)
