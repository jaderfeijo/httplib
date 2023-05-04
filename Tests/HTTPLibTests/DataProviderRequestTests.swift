import XCTest
@testable import HTTPLib

final class DataProviderRequestTests: XCTestCase {
	func testDataProviderRequestEquality() throws {
		let firstRequest = SimpleDataProviderRequest(
			method: .get,
			url: "test",
			headers: ["test":"value"],
			body: "test".data(using: .utf8)
		)
		let secondRequest = SimpleDataProviderRequest(
			method: .get,
			url: "test",
			headers: ["test":"value"],
			body: "test".data(using: .utf8)
		)
		let thirdRequest = SimpleDataProviderRequest(
			method: .post,
			url: "another-test",
			headers: ["another-test":"another-value"],
			body: "another-test".data(using: .utf8)
		)

		XCTAssertEqual(firstRequest, secondRequest)
		XCTAssertNotEqual(firstRequest, thirdRequest)
		XCTAssertNotEqual(secondRequest, thirdRequest)
	}
}
