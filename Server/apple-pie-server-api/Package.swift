// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "apple-pie",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMinor(from: "3.3.0")),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.2"),
        //.package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/fluent-mysql.git", .upToNextMinor(from: "3.0.1")),
        .package(url: "https://github.com/vapor/auth.git", .upToNextMinor(from: "2.0.4"))
        //.package(url: "https://github.com/vapor/fluent-sqlite.git", .upToNextMinor(from: "3.0.0"))
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "Leaf", /*"FluentPostgreSQL" */ "FluentMySQL"  /*FluentSQLite*/, "Authentication"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)

