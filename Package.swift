// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "neural",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
        .package(name:"Neuron", url: "https://github.com/wvabrinskas/neuron.git", .branch("optim4")),
      .package(name:"NeuronWebAPISDK", url: "git@github.com:wvabrinskas/NeuronWebAPISDK.git", .branch("master")),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Leaf", package: "leaf"),
                .product(name: "Vapor", package: "vapor"),
                "Neuron",
                "NeuronWebAPISDK"
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .target(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
