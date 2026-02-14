// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "DigiNoise-CLI",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "diginoise", targets: ["DigiNoiseCLI"]),
        .executable(name: "DigiNoiseMenuBar", targets: ["DigiNoiseMenuBar"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", exact: "1.1.4"),
    ],
    targets: [
        .executableTarget(
            name: "DigiNoiseCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "DigiNoiseShared"
            ],
            path: "Sources/CLI"
        ),
        .executableTarget(
            name: "DigiNoiseMenuBar",
            dependencies: ["DigiNoiseShared"],
            path: "Sources/MenuBar",
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "DigiNoiseShared",
            path: "Sources/Shared"
        )
    ]
)