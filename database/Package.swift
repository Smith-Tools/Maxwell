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
            name: "MaxwellMigrator",
            targets: ["MaxwellMigrator"]
        ),
        .library(
            name: "MaxwellDatabase",
            targets: ["MaxwellDatabase"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift", from: "0.14.1")
    ],
    targets: [
        .executableTarget(
            name: "MaxwellMigrator",
            dependencies: [
                "MaxwellDatabase",
                .product(name: "SQLite", package: "SQLite.swift")
            ]
        ),
        .target(
            name: "MaxwellDatabase",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift")
            ]
        ),
        .testTarget(
            name: "MaxwellDatabaseTests",
            dependencies: [
                "MaxwellDatabase",
                .product(name: "SQLite", package: "SQLite.swift")
            ]
        ),
    ]
)