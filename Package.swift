// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Labelo-iOS",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.15.2"),
    ]
)
