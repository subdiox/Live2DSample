// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Live2DMetal",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "Live2DMetal",
            targets: ["Live2DMetal"]
        ),
    ],
    targets: [
        .target(
            name: "Live2DMetal",
            dependencies: ["CubismNativeFramework"],
            publicHeadersPath: "."
        ),
        .target(
            name: "CubismNativeFramework",
            dependencies: ["Live2DCubismCore"],
            path: "Sources/CubismNativeFramework/src",
            exclude: ["CMakeLists.txt"],
            publicHeadersPath: ".",
            cSettings: [
                .unsafeFlags(["-fno-objc-arc"])
            ],
            cxxSettings: [
                .define("CSM_TARGET_IPHONE_ES2"),
                .unsafeFlags(["-fno-objc-arc"])
            ]
        ),
        .binaryTarget(
            name: "Live2DCubismCore",
            path: "Live2DCubismCore.xcframework"
        ),
    ],
    cxxLanguageStandard: .cxx14
)
