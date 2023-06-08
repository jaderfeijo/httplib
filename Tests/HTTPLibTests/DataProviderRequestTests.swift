import XCTest
@testable import HTTPLib

final class DataProviderRequestTests: XCTestCase {
	func testDataProviderRequestEquality() throws {
		let firstRequest = RawDataProviderRequest(
			method: .get,
			url: URL(string: "mock://test")!,
			headers: ["test":"value"],
			body: "test".data(using: .utf8)
		)
		let secondRequest = RawDataProviderRequest(
			method: .get,
			url: URL(string: "mock://test")!,
			headers: ["test":"value"],
			body: "test".data(using: .utf8)
		)
		let thirdRequest = RawDataProviderRequest(
			method: .post,
			url: URL(string: "mock://another-test")!,
			headers: ["another-test":"another-value"],
			body: "another-test".data(using: .utf8)
		)

		XCTAssertEqual(firstRequest, secondRequest)
		XCTAssertNotEqual(firstRequest, thirdRequest)
		XCTAssertNotEqual(secondRequest, thirdRequest)
	}
}
