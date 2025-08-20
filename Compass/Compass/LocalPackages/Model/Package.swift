// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Model",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Model",
            targets: ["GeneralModel",
                      "UploadModel"]),
    ],
    dependencies: [
        .package(path: "../ModelLoader"),
        .package(path: "../RuntimeError"),
        .package(path: "../MathLibrary")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GeneralModel",
            dependencies: [
                .product(name: "RuntimeError", package: "RuntimeError")
            ]),
        .target(
            name: "UploadModel",
            dependencies: [
                "GeneralModel",
                .product(name: "ModelLoader", package: "ModelLoader"),
                .product(name: "MathLibrary", package: "MathLibrary"),
            ]),
    ]
)
