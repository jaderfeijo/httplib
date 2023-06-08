import Foundation
import HTTPMethod

/// A request sent to a `DataProvider`.
public protocol DataProviderRequest: Equatable {
	var method: HTTPMethod { get }
	var url: URL { get }
	var headers: [String: String] { get }
	var body: Data? { get }
}
