import XCTest
@testable import HTTPLib

final class DataProviderResponseTests: XCTestCase {
	func testDataProviderResponseEquality() throws {
		XCTAssertEqual(
			DataProviderResponse.success(data: "test".data(using: .utf8)),
			DataProviderResponse.success(data: "test".data(using: .utf8))
		)
		XCTAssertEqual(
			DataProviderResponse.success(data: nil),
			DataProviderResponse.success(data: nil)
		)
		XCTAssertEqual(
			DataProviderResponse.error(code: .notFound, data: "test".data(using: .utf8)),
			DataProviderResponse.error(code: .notFound, data: "test".data(using: .utf8))
		)
		XCTAssertEqual(
			DataProviderResponse.error(code: .internalServerError, data: nil),
			DataProviderResponse.error(code: .internalServerError, data: nil)
		)
		XCTAssertEqual(
			DataProviderResponse.unreachable,
			DataProviderResponse.unreachable
		)

		XCTAssertNotEqual(
			DataProviderResponse.success(data: "test-1".data(using: .utf8)),
			DataProviderResponse.success(data: "test-2".data(using: .utf8))
		)
		XCTAssertNotEqual(
			DataProviderResponse.success(data: "test-1".data(using: .utf8)),
			DataProviderResponse.success(data: nil)
		)

		XCTAssertNotEqual(
			DataProviderResponse.error(code: .notFound, data: "test-1".data(using: .utf8)),
			DataProviderResponse.error(code: .notFound, data: "test-2".data(using: .utf8))
		)
		XCTAssertNotEqual(
			DataProviderResponse.error(code: .notFound, data: "test-1".data(using: .utf8)),
			DataProviderResponse.error(code: .notFound, data: nil)
		)
		XCTAssertNotEqual(
			DataProviderResponse.error(code: .notFound, data: nil),
			DataProviderResponse.error(code: .internalServerError, data: nil)
		)

		XCTAssertNotEqual(
			DataProviderResponse.success(data: nil),
			DataProviderResponse.error(code: nil, data: nil)
		)
		XCTAssertNotEqual(
			DataProviderResponse.success(data: nil),
			DataProviderResponse.unreachable
		)
		XCTAssertNotEqual(
			DataProviderResponse.error(code: nil, data: nil),
			DataProviderResponse.unreachable
		)
	}
}
