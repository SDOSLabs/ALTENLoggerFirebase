// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ALTENLoggerFirebase",
    platforms: [.iOS(.v14), .macOS(.v11), .tvOS(.v14), .watchOS(.v7)],
    products: [
        .library(
            name: "ALTENLoggerFirebase",
            targets: ["ALTENLoggerFirebase"])
    ],
    dependencies: [
        .package(url: "https://github.com/SDOSLabs/ALTENLoggerCore.git", .upToNextMajor(from: "1.1.0")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "10.15.0"))
    ],
    targets: [
        .target(
            name: "ALTENLoggerFirebase",
            dependencies: [
                .product(name: "ALTENLoggerCore", package: "ALTENLoggerCore"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk")
            ])
    ]
)
