// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Disk",
    platforms: [.iOS(.v9), .macOS(.v10_10), .tvOS(.v9), .watchOS(.v3)],
    products: [
        .library(name: "Disk", targets: ["Disk"])
    ],
    targets: [
        .target(
            name: "Disk",
            path: "Sources",
            exclude: ["DiskExample"]
        ),
        .testTarget(
            name: "DiskTests",
            dependencies: ["Disk"],
            path: "Tests",
            exclude:  ["DiskExample"]
        )
    ]
)
