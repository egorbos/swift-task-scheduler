// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "swift-task-scheduler",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "SwiftTaskScheduler", targets: ["SwiftTaskScheduler"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "SwiftTaskScheduler"),
        .testTarget(
            name: "SwiftTaskSchedulerTests",
            dependencies: ["SwiftTaskScheduler"]
        ),
    ]
)
