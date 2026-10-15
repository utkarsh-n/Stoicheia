// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Stoicheia",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [.library(name: "ChemistryCore", targets: ["ChemistryCore"])],
    targets: [
        .target(
            name: "ChemistryCore",
            path: "Core",
            exclude: ["SourceData", "Sources.md", "normalize.py"],
            resources: [.process("Resources")]
        ),
        .testTarget(name: "ChemistryCoreTests", dependencies: ["ChemistryCore"], path: "Tests")
    ]
)
