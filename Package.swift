// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "CWStatusBarNotification",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "CWStatusBarNotification",
            targets: ["CWStatusBarNotification"]
        )
    ],
    targets: [
        .target(
            name: "CWStatusBarNotification",
            path: "CWStatusBarNotification",
            publicHeadersPath: "."
        )
    ]
)
