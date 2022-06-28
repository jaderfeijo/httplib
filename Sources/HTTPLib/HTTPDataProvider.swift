import Foundation
import HTTPStatusCodes

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// HTTP Data Provider.
///
/// This class provides data via HTTP to it's consumers.
public class HTTPDataProvider: DataProvider {

	private let session: URLSession

	public init(session: URLSession = .shared) {
		self.session = session
	}

	public func send(_ request: DataProviderRequest, callback: @escaping DataProviderClosure) throws {
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

// MARK: - Private -

private extension HTTPDataProvider {
	func upload(_ request: URLRequest, body: Data, callback: @escaping DataProviderClosure) {
		session.uploadTask(with: request, from: body) { data, response, error in
			callback(
				.mappedResponse(
					from: data,
					response: response,
					error: error)
			)
		}.resume()
	}

	func download(_ request: URLRequest, callback: @escaping DataProviderClosure) {
		session.dataTask(with: request) { data, response, error in
			callback(
				.mappedResponse(
					from: data,
					response: response,
					error: error)
			)
		}.resume()
	}
}

private extension DataProviderResponse {
	static func mappedResponse(from data: Data?, response: URLResponse?, error: Error?) -> Self {
		guard error == nil else {
			return .unreachable
		}

		guard let httpResponse = (response as? HTTPURLResponse) else {
			return .error(code: nil, data: data)
		}

		guard let statusCode = HTTPStatusCode(rawValue: httpResponse.statusCode) else {
			return .error(code: nil, data: data)
		}

		guard statusCode.isSuccess else {
			return .error(code: statusCode, data: data)
		}

		return .success(data: data)
	}
}

private extension URLRequest {
	static func from(request: DataProviderRequest) throws -> URLRequest {
		struct InvalidURLError: Swift.Error {
			let url: String
		}

		guard let url = URL(string: request.url) else {
			throw InvalidURLError(url: request.url)
		}

		let urlRequest = NSMutableURLRequest(url: url)
		urlRequest.httpMethod = request.method.rawValue
		urlRequest.allHTTPHeaderFields = request.headers
		return urlRequest as URLRequest
	}
}
