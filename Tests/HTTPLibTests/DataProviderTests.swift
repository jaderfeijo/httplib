import XCTest
@testable import HTTPLib

class DataProviderTests: XCTestCase {
	var mockProvider: MockDataProvider!

	override func setUpWithError() throws {
		try super.setUpWithError()
		mockProvider = MockDataProvider()
		mockProvider.getResponse = { _ in .unreachable }
	}

	override func tearDownWithError() throws {
		mockProvider = nil
		try super.tearDownWithError()
	}
}

extension DataProviderTests {
	@available(macOS 10.15, iOS 13.0.0, *)
	func testSendAsyncSuccess() async throws {
		mockProvider.getResponse = { _ in
			.success(data: nil)
		}

		let response = try await mockProvider.send(
			.init(
				method: .get,
				url: "http://test/test",
				headers: nil,
				body: nil)
		)

		XCTAssertEqual(response, .success(data: nil))
	}

	@available(macOS 10.15, iOS 13.0.0, *)
	func testSendAsyncFailure() async throws {
		mockProvider.getResponse = { _ in
			.error(code: .internalServerError, data: nil)
		}

		let response = try await mockProvider.send(
			.init(
				method: .get,
				url: "http://test/test",
				headers: nil,
				body: nil)
		)

		XCTAssertEqual(response, .error(code: .internalServerError, data: nil))
	}

	@available(macOS 10.15, iOS 13.0.0, *)
	func testSendAsyncException() async throws {
		struct MockError: Swift.Error {}

		mockProvider.getResponse = { _ in
			throw MockError()
		}

		do {
			_ = try await mockProvider.send(
				.init(
					method: .get,
					url: "http://test/test",
					headers: nil,
					body: nil)
			)
			XCTFail("Expected exception to be thrown")
		} catch {
			XCTAssert(error is MockError)
		}
	}
}

extension DataProviderTests {
	func testDataProviderRequestEquality() throws {
		let firstRequest = DataProviderRequest(
			method: .get,
			url: "test",
			headers: ["test":"value"],
			body: "test".data(using: .utf8)
		)
		let secondRequest = DataProviderRequest(
			method: .get,
			url: "test",
			headers: ["test":"value"],
			body: "test".data(using: .utf8)
		)
		let thirdRequest = DataProviderRequest(
			method: .post,
			url: "another-test",
			headers: ["another-test":"another-value"],
			body: "another-test".data(using: .utf8)
		)
		
		XCTAssertEqual(firstRequest, secondRequest)
		XCTAssertNotEqual(firstRequest, thirdRequest)
		XCTAssertNotEqual(secondRequest, thirdRequest)
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

// MARK: - Private -

extension DataProviderTests {
	class MockDataProvider: DataProvider {
		typealias ResponseProvider = (DataProviderRequest) throws -> DataProviderResponse

		var getResponse: ResponseProvider!

		func send(_ request: DataProviderRequest, callback: @escaping DataProviderClosure) throws {
			callback(try getResponse(request))
		}
	}
}
