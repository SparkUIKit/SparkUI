// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SparkUI",
    platforms: [
        .iOS(.v16),      // 提升至 v16，解锁 Layout 协议
        .macOS(.v13)     // 提升至 v13
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
