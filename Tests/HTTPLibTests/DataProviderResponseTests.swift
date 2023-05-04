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
			.failure(.unreachable))
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
			.failure(
				.service(
					code: nil,
					data: "some-data".data(using: .utf8)!)
			)
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
			.failure(
				.service(
					code: nil,
					data: "some-data".data(using: .utf8)!)
			)
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
			.failure(
				.service(
					code: .notFound,
					data: "some-data".data(using: .utf8)!)
			)
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
				"some-data".data(using: .utf8)!)
		)
	}

	func testDataProviderResponseEquality() throws {
		XCTAssertEqual(
			DataProviderResponse.success("test".data(using: .utf8)),
			DataProviderResponse.success("test".data(using: .utf8))
		)
		XCTAssertEqual(
			DataProviderResponse.success(nil),
			DataProviderResponse.success(nil)
		)
		XCTAssertEqual(
			DataProviderResponse.failure(.service(code: .notFound, data: "test".data(using: .utf8))),
			DataProviderResponse.failure(.service(code: .notFound, data: "test".data(using: .utf8)))
		)
		XCTAssertEqual(
			DataProviderResponse.failure(.service(code: .internalServerError, data: nil)),
			DataProviderResponse.failure(.service(code: .internalServerError, data: nil))
		)
		XCTAssertEqual(
			DataProviderResponse.failure(.unreachable),
			DataProviderResponse.failure(.unreachable)
		)

		XCTAssertNotEqual(
			DataProviderResponse.success("test-1".data(using: .utf8)),
			DataProviderResponse.success("test-2".data(using: .utf8))
		)
		XCTAssertNotEqual(
			DataProviderResponse.success("test-1".data(using: .utf8)),
			DataProviderResponse.success(nil)
		)

		XCTAssertNotEqual(
			DataProviderResponse.failure(.service(code: .notFound, data: "test-1".data(using: .utf8))),
			DataProviderResponse.failure(.service(code: .notFound, data: "test-2".data(using: .utf8)))
		)
		XCTAssertNotEqual(
			DataProviderResponse.failure(.service(code: .notFound, data: "test-1".data(using: .utf8))),
			DataProviderResponse.failure(.service(code: .notFound, data: nil))
		)
		XCTAssertNotEqual(
			DataProviderResponse.failure(.service(code: .notFound, data: nil)),
			DataProviderResponse.failure(.service(code: .internalServerError, data: nil))
		)

		XCTAssertNotEqual(
			DataProviderResponse.success(nil),
			DataProviderResponse.failure(.service(code: nil, data: nil))
		)
		XCTAssertNotEqual(
			DataProviderResponse.success(nil),
			DataProviderResponse.failure(.unreachable)
		)
		XCTAssertNotEqual(
			DataProviderResponse.failure(.service(code: nil, data: nil)),
			DataProviderResponse.failure(.unreachable)
		)
	}
}
