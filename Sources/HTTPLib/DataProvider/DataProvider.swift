import Foundation
import HTTPStatusCodes
import HTTPMethod

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A closure that passes a response to a sent request.
public typealias DataProviderClosure = (DataProviderResponse) -> Void

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
	func send(_ request: any DataProviderRequest, callback: @escaping DataProviderClosure) throws
}

public extension DataProvider {
	/// Sends the specified request to the provider.
	/// - Parameter request: The request used to send/retrieve the data
	///   from the provider.
	/// - Returns:The data provider's response.
	@available(macOS 10.15, iOS 13.0.0, tvOS 13.0.0, watchOS 6.0, *)
	func send(_ request: any DataProviderRequest) async throws -> DataProviderResponse {
		try await withCheckedThrowingContinuation { continuation in
			do {
				try send(request) { response in
					continuation.resume(returning: response)
				}
			} catch {
				continuation.resume(throwing: error)
			}
		}
	}
}
