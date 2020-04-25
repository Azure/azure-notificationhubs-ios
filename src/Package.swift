// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WindowsAzureMessaging",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "WindowsAzureMessaging",
            targets: ["WindowsAzureMessaging"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "WindowsAzureMessaging",
            path: "WindowsAzureMessaging/WindowsAzureMessaging",
            cSettings: [
                .headerSearchPath("**")
            ],
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("UIKit")
            ]
        )
    ]
)
