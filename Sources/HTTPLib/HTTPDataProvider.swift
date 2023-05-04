import Foundation
import HTTPStatusCodes

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// HTTP Data Provider.
///
/// This class provides data via HTTP to its consumers.
public class HTTPDataProvider {
	let session: URLSession

	public init(session: URLSession = .shared) {
		self.session = session
	}
}

extension HTTPDataProvider: DataProvider {
	public func send(_ request: any DataProviderRequest, callback: @escaping DataProviderClosure) throws {
		let httpRequest = try URLRequest.from(
			request: request)

		if let body = request.body {
			upload(
				httpRequest,
				body: body,
				callback: callback)
		} else {
			download(
				httpRequest,
				callback: callback)
		}
	}
}

// MARK: - Internal -

extension URLRequest {
	struct InvalidURLError: Swift.Error {
		let url: String
	}

	static func from(request: any DataProviderRequest) throws -> URLRequest {
		guard let url = URL(string: request.url) else {
			throw InvalidURLError(url: request.url)
		}

		let urlRequest = NSMutableURLRequest(url: url)
		urlRequest.httpMethod = request.method.rawValue
		urlRequest.allHTTPHeaderFields = request.headers
		urlRequest.httpBody = request.body
		return urlRequest as URLRequest
	}
}

// MARK: - Private -

private extension HTTPDataProvider {
	func upload(_ request: URLRequest, body: Data, callback respondWith: @escaping DataProviderClosure) {
		session.uploadTask(with: request, from: body) { data, response, error in
			respondWith(
				.init(
					from: data,
					response: response,
					error: error)
			)
		}.resume()
	}

	func download(_ request: URLRequest, callback respondWith: @escaping DataProviderClosure) {
		session.dataTask(with: request) { data, response, error in
			respondWith(
				.init(
					from: data,
					response: response,
					error: error)
			)
		}.resume()
	}
}
