// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "HTTPLib",
	products: [
		.library(
			name: "HTTPLib",
			targets: ["HTTPLib"]),
	],
	dependencies: [
		.package(
			name: "HTTPStatusCodes",
			url: "https://github.com/rhodgkins/SwiftHTTPStatusCodes.git",
			.upToNextMajor(from: "3.3.0"))
	],
	targets: [
		.target(
			name: "HTTPLib",
			dependencies: ["HTTPStatusCodes"]),
		.testTarget(
			name: "HTTPLibTests",
			dependencies: ["HTTPLib"]),
	]
)
