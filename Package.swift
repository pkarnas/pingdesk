// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PingDesk",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .target(
            name: "PingDeskCore",
            path: "Sources/PingDeskCore"
        ),
        .executableTarget(
            name: "PingDesk",
            dependencies: ["PingDeskCore"],
            path: "Sources/PingDesk"
        ),
        .testTarget(
            name: "PingDeskTests",
            dependencies: ["PingDeskCore"],
            path: "Tests/PingDeskTests",
            swiftSettings: [
                .unsafeFlags([
                    "-F", "/Library/Developer/CommandLineTools/Library/Developer/Frameworks"
                ])
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-F", "/Library/Developer/CommandLineTools/Library/Developer/Frameworks",
                    "-framework", "Testing",
                    "-Xlinker", "-rpath",
                    "-Xlinker", "/Library/Developer/CommandLineTools/Library/Developer/Frameworks",
                    "-Xlinker", "-rpath",
                    "-Xlinker", "/Library/Developer/CommandLineTools/Library/Developer/usr/lib"
                ])
            ]
        )
    ]
)
