import Foundation
import HTTPStatusCodes

/// HTTP Data Provider.
///
/// This class provides data via HTTP to it's consumers.
public class HTTPDataProvider: DataProvider {

	private let session: URLSession

	public init(session: URLSession = .shared) {
		self.session = session
	}

	public func send(_ request: DataProviderRequest, callback: @escaping DataProviderClosure) {
		if let httpRequest = URLRequest.with(request: request) {
			print("HTTP: \(httpRequest.httpMethod ?? "nil") \(httpRequest.url?.absoluteString ?? "nil")")
			if let body = request.body {
				print(String(data: body as Data, encoding: String.Encoding.utf8) ?? "")
				session.uploadTask(with: httpRequest, from: body as Data, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
					if error != nil {
						print("Server unreachable")
						callback(.unreachable)
					} else if let httpResponse = (response as? HTTPURLResponse) {
						print("\(httpResponse.statusCode)")
						if let data = data {
							print(String(data: data, encoding: String.Encoding.utf8) ?? "")
						}
						
						if let statusCode = HTTPStatusCode(rawValue: httpResponse.statusCode) {
							if statusCode.isSuccess {
								callback(.success(data: data))
							} else {
								callback(.error(code: statusCode, data: data))
							}
						} else {
							callback(.error(code: nil, data: data))
						}
					} else {
						callback(.error(code: nil, data: data))
					}
					print("")
				}).resume()
			} else {
				session.dataTask(with: httpRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
					if error != nil {
						print("Server unreachable")
						callback(.unreachable)
					} else if let httpResponse = (response as? HTTPURLResponse) {
						print("\(httpResponse.statusCode)")
						if let data = data {
							print(String(data: data, encoding: String.Encoding.utf8) ?? "")
						}
						
						if let statusCode = HTTPStatusCode(rawValue: httpResponse.statusCode) {
							if statusCode.isSuccess {
								callback(.success(data: data))
							} else {
								callback(.error(code: statusCode, data: data))
							}
						} else {
							callback(.error(code: nil, data: data))
						}
					} else {
						callback(.error(code: nil, data: data))
					}
					print("")
				}).resume()
			}
		} else {
			callback(.error(code: nil, data: nil))
		}
	}
}

extension URLRequest {
	public static func with(request: DataProviderRequest) -> URLRequest? {
		if let url = URL(string: request.url) {
			let urlRequest = NSMutableURLRequest(url: url)
			urlRequest.httpMethod = request.method.rawValue
			urlRequest.allHTTPHeaderFields = request.headers
			return urlRequest as URLRequest
		} else {
			return nil
		}
	}
}
