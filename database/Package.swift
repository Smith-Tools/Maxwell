// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MaxwellDatabase",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "maxwell",
            targets: ["MaxwellCLI"]
        ),
        .library(
            name: "MaxwellDatabase",
            targets: ["MaxwellDatabase"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift", from: "0.14.1"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0")
    ],
    targets: [
        .executableTarget(
            name: "MaxwellCLI",
            dependencies: [
                "MaxwellDatabase",
                .product(name: "SQLite", package: "SQLite.swift"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .target(
            name: "MaxwellDatabase",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift")
            ]
        ),
    ]
)