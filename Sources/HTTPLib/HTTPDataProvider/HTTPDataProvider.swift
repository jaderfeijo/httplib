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

/// A HTTP response provided by URLSession
typealias HTTPResponse = (data: Data?, response: URLResponse?, error: Error?)

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
	func upload<T: Decodable>(_ request: URLRequest, body: Data, callback respondWith: @escaping DataProviderClosure<T>) {
		session.uploadTask(with: request, from: body) { [weak self] data, response, error in
			guard let self = self else { return }
			respondWith(
				.parse(
					from: (data: data, response: response, error: error),
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
					from: (data: data, response: response, error: error),
					using: self.decoder
				)
			)
		}.resume()
	}
}

private extension Result where Success: Decodable, Failure == DataProviderError {
	static func parse(from response: HTTPResponse, using decoder: JSONDecoder) -> Self {
		guard response.error == nil else {
			#warning("TODO: Improve mapping of Foundation errors. They might not be all reachability related")
			return .failure(.unreachable)
		}
		guard let httpResponse = (response.response as? HTTPURLResponse) else {
			return .failure(.service(code: nil, data: response.data))
		}
		guard let statusCode = HTTPStatusCode(rawValue: httpResponse.statusCode) else {
			return .failure(.service(code: nil, data: response.data))
		}
		guard statusCode.isSuccess else {
			return .failure(.service(code: statusCode, data: response.data))
		}

		do {
			let parsedData = try decoder.decode(
				Success.self,
				from: response.data ?? Data())
			return .success(parsedData)
		} catch let error as DecodingError {
			return .failure(.parsing(error))
		} catch {
			return .failure(.unknown(error))
		}
	}
}
