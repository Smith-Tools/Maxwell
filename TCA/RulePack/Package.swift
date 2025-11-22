// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MaxwellTCARulePack",
    platforms: [.macOS(.v13)],
    products: [
        .plugin(name: "MaxwellTCARulesPlugin", targets: ["MaxwellTCARulesPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/Smith-Tools/smith-validation.git", from: "1.0.9"),
        .package(url: "https://github.com/apple/swift-testing.git", from: "0.99.0")
    ],
    targets: [
        .executableTarget(
            name: "MaxwellTCARulesTool",
            dependencies: [
                .product(name: "SmithValidationCore", package: "smith-validation"),
                .product(name: "SmithValidation", package: "smith-validation"),
                .product(name: "MaxwellsTCARules", package: "smith-validation")
            ]
        ),
        .plugin(
            name: "MaxwellTCARulesPlugin",
            capability: .buildTool(),
            dependencies: ["MaxwellTCARulesTool"]
        ),
        .testTarget(
            name: "MaxwellTCARulePackTests",
            dependencies: [
                .product(name: "SmithValidationCore", package: "smith-validation"),
                .product(name: "SmithValidation", package: "smith-validation"),
                .product(name: "MaxwellsTCARules", package: "smith-validation"),
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/MaxwellTCARulePackTests"
        )
    ]
)
