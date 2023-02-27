// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "SwiftStringObfuscator",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        .executable(name: "swift_string_obfuscator", targets: ["swift_string_obfuscator"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", .upToNextMajor(from: "0.50700.1")),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.2"),
    ],
    targets: [
        .executableTarget(
            name: "swift_string_obfuscator",
            dependencies: [
                "SwiftStringObfuscatorCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "SwiftStringObfuscatorCore",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxParser", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "SwiftStringObfuscatorTests",
            dependencies: ["SwiftStringObfuscatorCore"]),
    ]
)
