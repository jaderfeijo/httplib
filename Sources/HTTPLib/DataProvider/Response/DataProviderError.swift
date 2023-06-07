import Foundation
import HTTPStatusCodes

public enum DataProviderError: Swift.Error {
	case unreachable
	case service(code: HTTPStatusCode?, data: Data?)
	case parsing(DecodingError)
	case unknown(Swift.Error?)
}

// MARK: - Equality -

extension DataProviderError: Equatable {
	public static func == (lhs: Self, rhs: Self) -> Bool {
		switch (lhs, rhs) {
		case (.unreachable, .unreachable):
			return true
		case let (.service(lhsCode, lhsData), .service(rhsCode, rhsData)):
			return lhsCode == rhsCode && lhsData == rhsData
		case (.parsing, .parsing):
			return true
		case (.unknown, .unknown):
			return true
		default:
			return false
		}
	}
}
