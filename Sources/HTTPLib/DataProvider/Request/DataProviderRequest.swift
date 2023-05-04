import Foundation
import HTTPMethod

/// A request sent to a `DataProvider`.
public protocol DataProviderRequest: Equatable {
	var method: HTTPMethod { get }
	var url: String { get }
	var headers: [String: String] { get }
	var body: Data? { get }
}

// MARK: - Equality -

extension DataProviderRequest {
	public static func == (left: any DataProviderRequest, right: any DataProviderRequest) -> Bool {
		let equalHeaders = (left.headers == right.headers)

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
