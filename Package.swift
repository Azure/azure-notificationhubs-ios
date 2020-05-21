// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WindowsAzureMessaging",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "WindowsAzureMessaging",
            targets: ["WindowsAzureMessaging"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "WindowsAzureMessaging",
            path: "src/WindowsAzureMessaging/WindowsAzureMessaging",
            cSettings: [
                .headerSearchPath("src/WindowsAzureMessaging/WindowsAzureMessaging/include/**")
            ]
//            linkerSettings: [
//                .linkedFramework("Foundation"),
//                .linkedFramework("UIKit")
//            ]
        )
    ]
)
