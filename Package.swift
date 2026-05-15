// swift-tools-version: 6.3
//
//  Package.swift
//  UIAlertFlow
//
//  Created by Mohammed Ashour on 15.05.26.
//  Licensed under the MIT License.
//

// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UIAlertFlow",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "UIAlertFlow",
            targets: ["UIAlertFlow"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "UIAlertFlow"
        ),

    ],
    swiftLanguageModes: [.v6]
)
