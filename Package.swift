// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "DaikiriSwift",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "DaikiriSwift",
            targets: ["DaikiriSwift"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/vadymmarkov/Fakery", .upToNextMinor(from: "5.1.0"))
    ],
    targets: [
        .target(
            name: "DaikiriSwift",
            dependencies: [],
            path: "DaikiriSwift/src"
        )
    ],
    swiftLanguageVersions: [.v5]
)
