import Foundation
import HTTPStatusCodes

public typealias DataProviderClosure = (DataProviderResponse) -> Void

public struct DataProviderRequest {
	public let method: HTTPMethod
	public let url: String
	public let headers: [String: String]?
	public let body: Data?
}

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

/// DataProvider protocol which allows data fetching logic
/// to be decoupled from the API instance. This is useful
/// for mocking results into the API without the need for
/// external libraries.
///
/// @since 1.0
public protocol DataProvider {

	/// Sends the specified request to the provider.
	///
	/// - parameter request: The request used to send/retrieve the data
	///   from the provider.
	/// - parameter callback: The callback called once the request completes
	///   executing the request.
	func send(_ request: DataProviderRequest, callback: @escaping DataProviderClosure)
}

public enum HTTPMethod: String {
	case get = "GET"
	case head = "HEAD"
	case post = "POST"
	case put = "PUT"
	case delete = "DELETE"
	case trace = "TRACE"
	case options = "OPTIONS"
	case connect = "CONNECT"
	case patch = "PATCH"
}

// MARK: - Equality -

extension DataProviderRequest: Equatable {
	public static func == (left: DataProviderRequest, right: DataProviderRequest) -> Bool {
		var equalHeaders = false
		if let leftHeaders = left.headers, let rightHeaders = right.headers {
			equalHeaders = (leftHeaders == rightHeaders)
		} else if left.headers == nil && right.headers == nil {
			equalHeaders = true
		}

		var equalBody = false
		if let leftBody = left.body, let rightBody = right.body {
			equalBody = (leftBody == rightBody)
		} else if left.body == nil && right.body == nil {
			equalBody = true
		}

		return (
			left.method == right.method &&
				left.url == right.url &&
				equalHeaders &&
				equalBody
		)
	}
}

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
