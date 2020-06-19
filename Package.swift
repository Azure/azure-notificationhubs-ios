// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let sources = ["", "Helpers", "HttpClient", "HttpClient/Util", "Internal", "Models", "Utils", "Vendor/Reachability"]
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
            path: "WindowsAzureMessaging/WindowsAzureMessaging",
            sources: sources,
            cSettings: sources.map { CSetting.headerSearchPath($0) }
        )
    ]
)

