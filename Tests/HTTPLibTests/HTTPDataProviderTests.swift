import XCTest
@testable import HTTPLib

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class HTTPDataProviderTests: XCTestCase {
	var configuration: URLSessionConfiguration!
	var session: URLSession!
	var sut: HTTPDataProvider!

	override func setUpWithError() throws {
		try super.setUpWithError()

		configuration = URLSessionConfiguration.default
		configuration.protocolClasses = [MockURLProtocol.self]
		session = URLSession(configuration: configuration)
		sut = HTTPDataProvider(session: session)
	}

	override func tearDownWithError() throws {
		configuration = nil
		session = nil
		sut = nil

		MockURLProtocol.requestHandler = nil

		try super.tearDownWithError()
	}
}

extension HTTPDataProviderTests {
	func testSendInvalidRequest() throws {
		let expectation = expectation(description: "request completed")

		do {
			let request = SimpleDataProviderRequest(
				method: .get,
				url: "   ",
				headers: [:],
				body: nil)
			try sut.send(request) { _ in
				XCTFail("Expected exception to be thrown")
			}
		} catch {
			expectation.fulfill()
		}

		waitForExpectations(timeout: 1.0)
	}

	func testSendPostRequest() throws {
		#if os(watchOS)
		/*
		 Due to what appears to be a bug in watchOS, this test does not run
		 correctly on watchOS and is therefore disabled on that platform.

		 It seems that, when using the `URLSession.uploadTask` method, the
		 `MockURLProtocol` injected into the `URLSessionConfiguration` is ignored,
		 which causes the code to actually hit the specified URL, bypassing the custom
		 protocol.
		*/
		print("Test case 'testSendPostRequest' ignored on watchOS")
		return
		#endif

		let expectation = expectation(description: "request completed")

		MockURLProtocol.requestHandler = { request in
			(
				HTTPURLResponse(
					url: URL(string: "test")!,
					statusCode: 200,
					httpVersion: nil,
					headerFields: nil)!,
				"response".data(using: .utf8)!
			)
		}

		let request = SimpleDataProviderRequest(
			method: .post,
			url: "test",
			headers: [:],
			body: "body".data(using: .utf8)!)
		try sut.send(request) { response in
			XCTAssertEqual(response, .success(data: "response".data(using: .utf8)!))
			expectation.fulfill()
		}

		waitForExpectations(timeout: 1.0)
	}

	func testSendGetRequest() throws {
		let expectation = expectation(description: "request completed")

		MockURLProtocol.requestHandler = { request in
			(
				HTTPURLResponse(
					url: URL(string: "test")!,
					statusCode: 200,
					httpVersion: nil,
					headerFields: nil)!,
				"response".data(using: .utf8)!
			)
		}

		let request = SimpleDataProviderRequest(
			method: .get,
			url: "test",
			headers: [:],
			body: nil)
		try sut.send(request) { response in
			XCTAssertEqual(response, .success(data: "response".data(using: .utf8)!))
			expectation.fulfill()
		}

		waitForExpectations(timeout: 1.0)
	}

	func testSendTimeout() throws {
		let expectation = expectation(description: "request completed")

		MockURLProtocol.requestHandler = { _ in
			throw URLError(URLError.timedOut)
		}

		let request = SimpleDataProviderRequest(
			method: .get,
			url: "test",
			headers: [:],
			body: nil)
		try sut.send(request) { response in
			XCTAssertEqual(response, .unreachable)
			expectation.fulfill()
		}

		waitForExpectations(timeout: 1.0)
	}
}

extension HTTPDataProviderTests {
	func testDataProviderResponseMappedResponseError() throws {
		struct MockError: Swift.Error { }
		XCTAssertEqual(
			DataProviderResponse.mappedResponse(
				from: nil,
				response: nil,
				error: MockError()),
			.unreachable)
	}

	func testDataProviderResponseMappedResponseNotHTTPResponse() throws {
		XCTAssertEqual(
			DataProviderResponse.mappedResponse(
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
			DataProviderResponse.mappedResponse(
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
			DataProviderResponse.mappedResponse(
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
			DataProviderResponse.mappedResponse(
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
}

extension HTTPDataProviderTests {
	func testURLRequestFromDataProviderRequestSuccess() throws {
		let request = SimpleDataProviderRequest(
			method: .get,
			url: "http://test/test",
			headers: ["key": "value"],
			body: "test".data(using: .utf8)!)
		let urlRequest = try URLRequest.from(
			request: request)

		XCTAssertEqual(urlRequest.httpMethod, "GET")
		XCTAssertEqual(urlRequest.url, URL(string: "http://test/test")!)
		XCTAssertEqual(urlRequest.allHTTPHeaderFields, ["key": "value"])
		XCTAssertEqual(urlRequest.httpBody, "test".data(using: .utf8)!)
	}

	func testURLRequestFromDataProviderRequestInvalidURL() throws {
		let request = SimpleDataProviderRequest(
			method: .get,
			url: "   ", // invalid url
			headers: ["key": "value"],
			body: "test".data(using: .utf8)!)

		do {
			_ = try URLRequest.from(
				request: request)
			XCTFail("Expected exception to be thrown")
		} catch {
			XCTAssert(error is URLRequest.InvalidURLError)
			XCTAssertEqual((error as? URLRequest.InvalidURLError)?.url, "   ")
		}
	}
}

// MARK: - Private -

private extension HTTPDataProviderTests {
	class MockURLProtocol: URLProtocol {
		typealias ResponseProvider = (URLRequest) throws -> (HTTPURLResponse, Data?)

		static var requestHandler: ResponseProvider!

		override class func canInit(with request: URLRequest) -> Bool {
			return true
		}

		override class func canonicalRequest(for request: URLRequest) -> URLRequest {
			return request
		}

		override func startLoading() {
			do {
				let (response, data) = try Self.requestHandler!(request)

				client?.urlProtocol(
					self,
					didReceive: response,
					cacheStoragePolicy: .notAllowed)

				if let data = data {
					client?.urlProtocol(
						self,
						didLoad: data)
				}

				client?.urlProtocolDidFinishLoading(self)
			} catch {
				client?.urlProtocol(
					self,
					didFailWithError: error)
			}
		}

		override func stopLoading() {
			//
		}
	}
}
