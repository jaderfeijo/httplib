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
			url: "https://github.com/jaderfeijo/SwiftHTTPStatusCodes.git",
			.branch("master")
		)
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
