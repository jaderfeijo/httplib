import Foundation
import HTTPStatusCodes

/// Data Provider Response.
///
/// - Success: Represents a successful response from the provider.
/// - ProviderError: Represents an error from the provider.
/// - ProviderUnreachable: Represents a reachability error with the provider.
public enum DataProviderResponse {
	case success(data: Data?)
	case error(code: HTTPStatusCode?, data: Data?)
	case unreachable
}

// MARK: - Equality -

extension DataProviderResponse: Equatable {
	public static func == (left: DataProviderResponse, right: DataProviderResponse) -> Bool {
		switch (left, right) {
		case (.success(let leftData), .success(let rightData)):
			return leftData == rightData
		case (.error(let leftCode, let leftData), .error(let rightCode, let rightData)):
			return leftCode == rightCode && leftData == rightData
		case (.unreachable, .unreachable):
			return true
		default:
			return false
		}
	}
}
