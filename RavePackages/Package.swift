// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RavePackages",
    defaultLocalization: "en", 
    platforms: [.iOS(.v17),.macOS(.v14),.watchOS(.v10)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "RaveLibrary",
            targets: ["RaveLibrary"]),
        .library(
            name: "RavePackages",
            targets: ["RavePackages"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "RaveLibrary"
        ),
        .target(
            name: "RavePackages",
            dependencies: ["RaveLibrary"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
        .testTarget(
            name: "RavePackagesTests",
            dependencies: ["RavePackages","RaveLibrary"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        )
        

    ]
)

//let package = Package(
//    name: "RavePackages",
//    defaultLocalization: "en",
//    platforms: [.iOS(.v17),.macOS(.v14),.watchOS(.v10)],
//    products: [
//        // Products define the executables and libraries a package produces, making them visible to other packages.
//        .library(
//            name: "RavePackages",
//            targets: ["RavePackages"]),
//    ],
//    targets: [
//        // Targets are the basic building blocks of a package, defining a module or a test suite.
//        // Targets can depend on other targets in this package and products from dependencies.
//        .target(
//            name: "RavePackages"
//        ),
//        .testTarget(
//            name: "RavePackagesTests",
//            dependencies: ["RavePackages"]),
//    ]
//)
