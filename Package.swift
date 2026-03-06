// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SparkUI",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(name: "SparkUI", targets: ["SparkUI"]),
    ],
    targets: [
        .target(name: "SparkUI"),
        .testTarget(
            name: "SparkUITests",
            dependencies: ["SparkUI"]
        ),
    ]
)
