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
	@available(macOS 10.15, iOS 13.0.0, tvOS 13.0.0, watchOS 6.0, *)
	func testSendAsyncSuccess() async throws {
		mockProvider.getResponse = { _ in
			.success(data: nil)
		}

		let response = try await mockProvider.send(
			SimpleDataProviderRequest(
				method: .get,
				url: "http://test/test",
				headers: [:],
				body: nil)
		)

		XCTAssertEqual(response, .success(data: nil))
	}

	@available(macOS 10.15, iOS 13.0.0, tvOS 13.0.0, watchOS 6.0, *)
	func testSendAsyncFailure() async throws {
		mockProvider.getResponse = { _ in
			.error(code: .internalServerError, data: nil)
		}

		let response = try await mockProvider.send(
			SimpleDataProviderRequest(
				method: .get,
				url: "http://test/test",
				headers: [:],
				body: nil)
		)

		XCTAssertEqual(response, .error(code: .internalServerError, data: nil))
	}

	@available(macOS 10.15, iOS 13.0.0, tvOS 13.0.0, watchOS 6.0, *)
	func testSendAsyncException() async throws {
		struct MockError: Swift.Error {}

		mockProvider.getResponse = { _ in
			throw MockError()
		}

		do {
			_ = try await mockProvider.send(
				SimpleDataProviderRequest(
					method: .get,
					url: "http://test/test",
					headers: [:],
					body: nil)
			)
			XCTFail("Expected exception to be thrown")
		} catch {
			XCTAssert(error is MockError)
		}
	}
}

// MARK: - Private -

extension DataProviderTests {
	class MockDataProvider: DataProvider {
		typealias ResponseProvider = (any DataProviderRequest) throws -> DataProviderResponse

		var getResponse: ResponseProvider!

		func send(_ request: any DataProviderRequest, callback: @escaping DataProviderClosure) throws {
			callback(try getResponse(request))
		}
	}
}
