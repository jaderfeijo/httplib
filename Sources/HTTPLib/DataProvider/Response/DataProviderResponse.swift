import Foundation
import HTTPStatusCodes

public typealias DataProviderResponse = Result<Data?, DataProviderError>

public enum DataProviderError: Swift.Error {
	case unreachable
	case service(code: HTTPStatusCode?, data: Data?)
}

// MARK: - Equality -

extension DataProviderError: Equatable {
	public static func == (lhs: Self, rhs: Self) -> Bool {
		switch (lhs, rhs) {
		case (.unreachable, .unreachable):
			return true
		case let (.service(lhsCode, lhsData), .service(rhsCode, rhsData)):
			return lhsCode == rhsCode && lhsData == rhsData
		default:
			return false
		}
	}
}

// MARK: - Internal -

extension DataProviderResponse {
	init(from data: Data?, response: URLResponse?, error: Error?) {
		guard error == nil else {
			self = .failure(.unreachable); return
		}
		guard let httpResponse = (response as? HTTPURLResponse) else {
			self = .failure(.service(code: nil, data: data)); return
		}
		guard let statusCode = HTTPStatusCode(rawValue: httpResponse.statusCode) else {
			self = .failure(.service(code: nil, data: data)); return
		}
		guard statusCode.isSuccess else {
			self = .failure(.service(code: statusCode, data: data)); return
		}
		self = .success(data)
	}
}
