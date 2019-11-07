// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "CombineRealm",
    platforms: [
        .iOS("13.0"),
    ],
    products: [
        .library(name: "CombineRealm", targets: ["CombineRealm"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/realm/realm-cocoa.git",
            from: "3.21.0"
        )
    ],
    targets: [
        .target(
            name: "CombineRealm",
            dependencies: [
                "Realm",
                "RealmSwift"
            ],
            path: "CombineRealm"
        ),
        .testTarget(
            name: "CombineRealmTests",
            dependencies: ["CombineRealm"],
            path: "CombineRealmTests"
        )
    ],
    swiftLanguageVersions: [.v5]
)
