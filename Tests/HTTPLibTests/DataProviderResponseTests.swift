import XCTest
@testable import HTTPLib

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class DataProviderResponseTests: XCTestCase {
	func testDataProviderResponseMappedResponseError() throws {
		struct MockError: Swift.Error { }
		XCTAssertEqual(
			DataProviderResponse<Empty>.parse(
				from: .init(
					data: nil,
					response: nil,
					error: MockError()),
				using: .init()
			),
			.failure(.unreachable))
	}

	func testDataProviderResponseMappedResponseNotHTTPResponse() throws {
		XCTAssertEqual(
			DataProviderResponse<Empty>.parse(
				from: .init(
					data: "some-data".data(using: .utf8)!,
					response: URLResponse(
						url: .init(string: "test-url")!,
						mimeType: nil,
						expectedContentLength: 0,
						textEncodingName: nil),
					error: nil),
				using: .init()
			),
			.failure(
				.service(
					code: nil,
					data: "some-data".data(using: .utf8)!)
			)
		)
	}

	func testDataProviderResponseMappedResponseHTTPErrorNoStatusCode() throws {
		XCTAssertEqual(
			DataProviderResponse<Empty>.parse(
				from: .init(
					data: "some-data".data(using: .utf8)!,
					response: HTTPURLResponse(
						url: .init(string: "test-url")!,
						statusCode: 0,
						httpVersion: nil,
						headerFields: nil),
					error: nil),
				using: .init()
			),
			.failure(
				.service(
					code: nil,
					data: "some-data".data(using: .utf8)!)
			)
		)
	}

	func testDataProviderResponseMappedResponseHTTPError() throws {
		XCTAssertEqual(
			DataProviderResponse<Empty>.parse(
				from: .init(
					data: "some-data".data(using: .utf8)!,
					response: HTTPURLResponse(
						url: .init(string: "test-url")!,
						statusCode: 404,
						httpVersion: nil,
						headerFields: nil),
					error: nil),
				using: .init()
			),
			.failure(
				.service(
					code: .notFound,
					data: "some-data".data(using: .utf8)!)
			)
		)
	}

	func testDataProviderResponseMappedResponseSuccess() throws {
		XCTAssertEqual(
			DataProviderResponse<Mock>.parse(
				from: .init(
					data: "{\"value\":\"Value\"}".data(using: .utf8)!,
					response: HTTPURLResponse(
						url: .init(string: "test-url")!,
						statusCode: 200,
						httpVersion: nil,
						headerFields: nil),
					error: nil),
				using: .init()
			),
			.success(Mock(value: "Value"))
		)
	}

	func testDataProviderResponseEquality() throws {
		XCTAssertEqual(
			DataProviderResponse.success(Mock(value: "Value")),
			DataProviderResponse.success(Mock(value: "Value"))
		)
		XCTAssertEqual(
			DataProviderResponse<Empty>.success(.empty),
			DataProviderResponse<Empty>.success(.empty)
		)
		XCTAssertEqual(
			DataProviderResponse<Empty>.failure(.service(code: .notFound, data: "test".data(using: .utf8))),
			DataProviderResponse<Empty>.failure(.service(code: .notFound, data: "test".data(using: .utf8)))
		)
		XCTAssertEqual(
			DataProviderResponse<Empty>.failure(.service(code: .internalServerError, data: nil)),
			DataProviderResponse<Empty>.failure(.service(code: .internalServerError, data: nil))
		)
		XCTAssertEqual(
			DataProviderResponse<Empty>.failure(.unreachable),
			DataProviderResponse<Empty>.failure(.unreachable)
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
			DataProviderResponse<Empty>.failure(.service(code: .notFound, data: "test-1".data(using: .utf8))),
			DataProviderResponse<Empty>.failure(.service(code: .notFound, data: "test-2".data(using: .utf8)))
		)
		XCTAssertNotEqual(
			DataProviderResponse<Empty>.failure(.service(code: .notFound, data: "test-1".data(using: .utf8))),
			DataProviderResponse<Empty>.failure(.service(code: .notFound, data: nil))
		)
		XCTAssertNotEqual(
			DataProviderResponse<Empty>.failure(.service(code: .notFound, data: nil)),
			DataProviderResponse<Empty>.failure(.service(code: .internalServerError, data: nil))
		)

		XCTAssertNotEqual(
			DataProviderResponse<Empty>.success(.empty),
			DataProviderResponse<Empty>.failure(.service(code: nil, data: nil))
		)
		XCTAssertNotEqual(
			DataProviderResponse<Empty>.success(.empty),
			DataProviderResponse<Empty>.failure(.unreachable)
		)
		XCTAssertNotEqual(
			DataProviderResponse<Empty>.failure(.service(code: nil, data: nil)),
			DataProviderResponse<Empty>.failure(.unreachable)
		)
	}
}

// MARK: - Private -

extension DataProviderResponseTests {
	struct Mock: Decodable, Equatable {
		let value: String
	}
}
