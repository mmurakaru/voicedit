// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "voicedit",
    platforms: [.macOS(.v13)],
    targets: [
        .target(name: "ReadCore"),
        .executableTarget(name: "ve", dependencies: ["ReadCore"]),
        .testTarget(name: "ReadCoreTests", dependencies: ["ReadCore"]),
    ]
)
