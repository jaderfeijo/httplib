import XCTest
@testable import HTTPLib

final class DataProviderResponseTests: XCTestCase {
	func testDataProviderResponseMappedResponseError() throws {
		struct MockError: Swift.Error { }
		XCTAssertEqual(
			DataProviderResponse(
				from: nil,
				response: nil,
				error: MockError()),
			.unreachable)
	}

	func testDataProviderResponseMappedResponseNotHTTPResponse() throws {
		XCTAssertEqual(
			DataProviderResponse(
				from: "some-data".data(using: .utf8)!,
				response: URLResponse(
					url: .init(string: "test-url")!,
					mimeType: nil,
					expectedContentLength: 0,
					textEncodingName: nil),
				error: nil),
			.error(
				code: nil,
				data: "some-data".data(using: .utf8)!)
		)
	}

	func testDataProviderResponseMappedResponseHTTPErrorNoStatusCode() throws {
		XCTAssertEqual(
			DataProviderResponse(
				from: "some-data".data(using: .utf8)!,
				response: HTTPURLResponse(
					url: .init(string: "test-url")!,
					statusCode: 0,
					httpVersion: nil,
					headerFields: nil),
				error: nil),
			.error(
				code: nil,
				data: "some-data".data(using: .utf8)!)
		)
	}

	func testDataProviderResponseMappedResponseHTTPError() throws {
		XCTAssertEqual(
			DataProviderResponse(
				from: "some-data".data(using: .utf8)!,
				response: HTTPURLResponse(
					url: .init(string: "test-url")!,
					statusCode: 404,
					httpVersion: nil,
					headerFields: nil),
				error: nil),
			.error(
				code: .notFound,
				data: "some-data".data(using: .utf8)!)
		)
	}

	func testDataProviderResponseMappedResponseSuccess() throws {
		XCTAssertEqual(
			DataProviderResponse(
				from: "some-data".data(using: .utf8)!,
				response: HTTPURLResponse(
					url: .init(string: "test-url")!,
					statusCode: 200,
					httpVersion: nil,
					headerFields: nil),
				error: nil),
			.success(
				data: "some-data".data(using: .utf8)!)
		)
	}

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
