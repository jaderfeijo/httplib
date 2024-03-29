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
				"{\"response\":\"value\"}".data(using: .utf8)!
			)
		}

		let request = RawDataProviderRequest(
			method: .post,
			url: URL(string: "mock://test")!,
			headers: [:],
			body: "body".data(using: .utf8)!)
		try sut.send(request) { response in
			XCTAssertEqual(response, .success(MockResponse(response: "value")))
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
				"{\"response\":\"value\"}".data(using: .utf8)!
			)
		}

		let request = RawDataProviderRequest(
			method: .get,
			url: URL(string: "mock://test")!,
			headers: [:],
			body: nil)
		try sut.send(request) { response in
			XCTAssertEqual(response, .success(MockResponse(response: "value")))
			expectation.fulfill()
		}

		waitForExpectations(timeout: 1.0)
	}

	func testSendTimeout() throws {
		let expectation = expectation(description: "request completed")

		MockURLProtocol.requestHandler = { _ in
			throw URLError(URLError.timedOut)
		}

		let request = RawDataProviderRequest(
			method: .get,
			url: URL(string: "mock://test")!,
			headers: [:],
			body: nil)
		try sut.send<Empty>(request) { (response: DataProviderResponse<Empty>) in
			XCTAssertEqual(response, .failure(.unreachable))
			expectation.fulfill()
		}

		waitForExpectations(timeout: 1.0)
	}
}

extension HTTPDataProviderTests {
	func testURLRequestFromDataProviderRequestSuccess() throws {
		let request = RawDataProviderRequest(
			method: .get,
			url: URL(string: "http://test/test")!,
			headers: ["key": "value"],
			body: "test".data(using: .utf8)!)
		let urlRequest = try URLRequest.from(
			request: request)

		XCTAssertEqual(urlRequest.httpMethod, "GET")
		XCTAssertEqual(urlRequest.url, URL(string: "http://test/test")!)
		XCTAssertEqual(urlRequest.allHTTPHeaderFields, ["key": "value"])
		XCTAssertEqual(urlRequest.httpBody, "test".data(using: .utf8)!)
	}
}

// MARK: - Private -

private extension HTTPDataProviderTests {
	struct MockResponse: Decodable, Equatable {
		let response: String
	}
}

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
