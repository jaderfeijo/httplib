import Foundation
import HTTPMethod

/**
 A simple implementation of a data provider request which takes
 raw data to send to a server over HTTP.
 */
public struct RawDataProviderRequest: DataProviderRequest {
	public let method: HTTPMethod
	public let url: String
	public let headers: [String: String]
	public let body: Data?

	public init(
		method: HTTPMethod,
		url: String,
		headers: [String: String] = [:],
		body: Data? = nil) {

		self.method = method
		self.url = url
		self.headers = headers
		self.body = body
	}
}
