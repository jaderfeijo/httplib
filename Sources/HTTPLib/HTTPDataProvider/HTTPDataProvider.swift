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
	let decoder: JSONDecoder

	public init(
		session: URLSession = .shared,
		decoder: JSONDecoder = .init()) {

		self.session = session
		self.decoder = decoder
	}
}

extension HTTPDataProvider: DataProvider {
	public func send<T: Decodable>(_ request: any DataProviderRequest, callback: @escaping DataProviderClosure<T>) throws {
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
	static func from(request: any DataProviderRequest) throws -> URLRequest {
		let urlRequest = NSMutableURLRequest(url: request.url)
		urlRequest.httpMethod = request.method.rawValue
		urlRequest.allHTTPHeaderFields = request.headers
		urlRequest.httpBody = request.body
		return urlRequest as URLRequest
	}
}

// MARK: - Private -

private extension HTTPDataProvider {
	func upload<T: Decodable>(_ request: URLRequest, body: Data, callback respondWith: @escaping DataProviderClosure<T>) {
		session.uploadTask(with: request, from: body) { [weak self] data, response, error in
			guard let self = self else { return }
			respondWith(
				.parse(
					from: .init(data: data, response: response, error: error),
					using: self.decoder
				)
			)
		}.resume()
	}

	func download<T: Decodable>(_ request: URLRequest, callback respondWith: @escaping DataProviderClosure<T>) {
		session.dataTask(with: request) { [weak self] data, response, error in
			guard let self = self else { return }
			respondWith(
				.parse(
					from: .init(data: data, response: response, error: error),
					using: self.decoder
				)
			)
		}.resume()
	}
}
