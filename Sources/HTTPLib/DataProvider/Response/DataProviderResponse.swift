import Foundation
import HTTPStatusCodes

/// A data provider response, which encapsulates a generic type
/// representing the returned value.
public typealias DataProviderResponse<T: Decodable> = Result<T, DataProviderError>

/// A closure that passes a response to a sent request.
public typealias DataProviderClosure<T: Decodable> = (DataProviderResponse<T>) -> Void

/// An Empty decodable structure for requests which do not return any data.
public struct Empty: Decodable, Equatable {}

public extension Empty {
	static let empty: Empty = .init()
}

// MARK: - Internal -

struct HTTPResponse {
	let data: Data?
	let response: URLResponse?
	let error: Error?
}

extension Result where Success: Decodable, Failure == DataProviderError {
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
