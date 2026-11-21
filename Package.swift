// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Keychain",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Keychain",
            targets: ["Keychain"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Keychain",
            dependencies: [],
            path: "Source"),
    ]
)
