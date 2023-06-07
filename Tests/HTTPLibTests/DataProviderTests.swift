import XCTest
@testable import HTTPLib

class DataProviderTests: XCTestCase {
	var mockProvider: MockDataProvider<Empty>!

	override func setUpWithError() throws {
		try super.setUpWithError()
		mockProvider = MockDataProvider()
		mockProvider.getResponse = { _ in
			DataProviderResponse<Empty>.failure(.unreachable)
		}
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
			DataProviderResponse<Empty>.success(.empty)
		}

		let response: Empty = try await mockProvider.send(
			RawDataProviderRequest(
				method: .get,
				url: "http://test/test",
				headers: [:],
				body: nil)
		)

		XCTAssertEqual(response, Empty())
	}

	@available(macOS 10.15, iOS 13.0.0, tvOS 13.0.0, watchOS 6.0, *)
	func testSendAsyncFailure() async throws {
		mockProvider.getResponse = { _ in
			DataProviderResponse<Empty>.failure(.service(code: .internalServerError, data: nil))
		}

		await XCTAssertThrowsErrorAsync(
			try await mockProvider.send<Empty>(
				RawDataProviderRequest(
					method: .get,
					url: "http://test/test",
					headers: [:],
					body: nil)
			),
			error: DataProviderError.service(code: .internalServerError, data: nil)
		)
	}

	@available(macOS 10.15, iOS 13.0.0, tvOS 13.0.0, watchOS 6.0, *)
	func testSendAsyncException() async throws {
		struct MockError: Swift.Error {}

		mockProvider.getResponse = { _ in
			throw MockError()
		}

		do {
			_ = try await mockProvider.send(
				RawDataProviderRequest(
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
	typealias ResponseProvider<T: Decodable> = (any DataProviderRequest) throws -> DataProviderResponse<T>

	class MockDataProvider<Response: Decodable>: DataProvider {
		var getResponse: ResponseProvider<Response>!

		func send<T: Decodable>(_ request: any DataProviderRequest, callback: @escaping DataProviderClosure<T>) throws {
			let response = try getResponse(request)
			guard let typedResponse = response as? DataProviderResponse<T> else {
				fatalError("Invalid response type '\(response)'")
			}
			callback(typedResponse)
		}
	}
}

private extension XCTestCase {
	 func XCTAssertThrowsErrorAsync<T, E: Error & Equatable>(
		  _ expression: @autoclosure () async throws -> T,
		  error: E,
		  _ message: @autoclosure () -> String = "",
		  file: StaticString = #filePath,
		  line: UInt = #line,
		  _ errorHandler: ((E) -> Void)? = nil
	 ) async {
		  do {
				let result = try await expression()
				XCTFail("Expected error of type \(E.self), but closure returned \(result)", file: file, line: line)
		  } catch let caughtError as E {
				XCTAssertEqual(caughtError, error, message(), file: file, line: line)
				errorHandler?(caughtError)
		  } catch {
				XCTFail("Expected error of type \(E.self), but caught error of type \(type(of: error))", file: file, line: line)
		  }
	 }
}
