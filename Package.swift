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
            sources: ["", "Helpers", "HttpClient", "HttpClient/Util", "Internal", "Models", "Utils", "Vendor/Reachability"],
            cSettings: [
                .headerSearchPath(""),
                .headerSearchPath("Helpers"),
                .headerSearchPath("HttpClient"),
                .headerSearchPath("HttpClient/Util"),
                .headerSearchPath("Internal"),
                .headerSearchPath("Models"),
                .headerSearchPath("Utils"),
                .headerSearchPath("Vendor/Reachability"),
            ]
        )
    ]
)

