// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CustomTypeConversionCoder",
    products: [
        .library(
            name: "CustomTypeConversionCoder",
            targets: ["CustomTypeConversionCoder"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CustomTypeConversionCoder",
            dependencies: []),
        .testTarget(
            name: "CustomTypeConversionCoderTests",
            dependencies: ["CustomTypeConversionCoder"]),
    ]
)
