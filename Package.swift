// swift-tools-version:5.5

import PackageDescription

let package = Package(
	name: "HTTPLib",
	platforms: [
		.iOS(.v9),
		.macOS(.v10_10),
		.tvOS(.v9),
		.watchOS(.v2)
	],
	products: [
		.library(
			name: "HTTPLib",
			targets: ["HTTPLib"])
	],
	dependencies: [
		.package(
			url: "https://github.com/jaderfeijo/SwiftHTTPStatusCodes.git",
			.upToNextMajor(from: "3.4.0"))
	],
	targets: [
		.target(
			name: "HTTPLib",
			dependencies: [
				.product(
					name: "HTTPStatusCodes",
					package: "SwiftHTTPStatusCodes")
			]
		),
		.testTarget(
			name: "HTTPLibTests",
			dependencies: ["HTTPLib"]),
	]
)
