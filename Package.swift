// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PingDesk",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "PingDesk",
            path: "Sources/PingDesk"
        )
    ]
)
