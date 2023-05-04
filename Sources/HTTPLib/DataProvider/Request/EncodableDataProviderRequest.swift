import Foundation
import HTTPMethod

/// A request sent to a `DataProvider`, with an encoded body.
public struct EncodableDataProviderRequest<T: Encodable>: DataProviderRequest {
	public let method: HTTPMethod
	public let url: String
	public let headers: [String: String]
	public let body: Data?

	public init(
		method: HTTPMethod,
		url: String,
		headers: [String: String] = [:],
		body: T,
		encoder: JSONEncoder = .init()) throws {

		self.method = method
		self.url = url
		self.headers = headers
		self.body = try encoder.encode(body)
	}
}
