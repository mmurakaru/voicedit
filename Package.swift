// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "voicedit",
    platforms: [.macOS(.v13)],
    targets: [
        .target(name: "ReadCore"),
        .executableTarget(name: "read", dependencies: ["ReadCore"]),
        .testTarget(name: "ReadCoreTests", dependencies: ["ReadCore"]),
    ]
)
