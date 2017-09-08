// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SwiftPack",
    products: [
        .executable(
            name: "swift-pack",
            targets: ["SwiftPack"])
    ],
    dependencies: [
        .package(url: "https://github.com/omochi/SwiftSyntax.git", from: "0.1.0"),
        .package(url: "https://github.com/omochi/DebugReflect.git", from: "0.2.2")
    ],
    targets: [
        .target(
            name: "SwiftPack",
            dependencies: ["SwiftSyntax", "DebugReflect"]),
    ]
)
