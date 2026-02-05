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
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "DigiNoiseCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources/CLI"
        ),
        .executableTarget(
            name: "DigiNoiseMenuBar",
            dependencies: [],
            path: "Sources/MenuBar"
        )
    ]
)
