// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PasswordKit",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "PasswordKit", targets: ["PasswordKit"]),
        .library(name: "PasswordClipboard", targets: ["PasswordClipboard"]),
    ],
    targets: [
        .target(
            name: "PasswordKit",
            resources: [.copy("Resources/eff_large_wordlist.txt")]
        ),
        .target(name: "PasswordClipboard"),
        .testTarget(
            name: "PasswordKitTests",
            dependencies: ["PasswordKit"],
            resources: [.copy("test-vectors.json")]
        ),
    ]
)

