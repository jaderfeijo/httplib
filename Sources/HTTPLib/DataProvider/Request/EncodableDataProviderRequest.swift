import Foundation
import HTTPMethod

/// A request sent to a `DataProvider`, with an encoded body.
public struct EncodableDataProviderRequest<T: Encodable>: DataProviderRequest {
	public let method: HTTPMethod
	public let url: URL
	public let headers: [String: String]
	public let body: Data?

	/**
	 Initializes a new instance of `DataProviderRequest` with the given parameters.

	 - Parameters:
	   - method: The HTTP method used for the request.
	   - url: The URL of the endpoint where the data is being requested from.
	   - headers: Additional headers to be sent with the request.
	   - body: The body of the request.
	   - encoder: The JSON encoder to use to encode the request body. This parameter is optional and defaults to a new instance of `JSONEncoder`.

	 - Throws: An error if the provided `body` parameter cannot be encoded by the `JSONEncoder`.

	 - Note: This initializer encodes the `body` parameter using the provided `encoder`, and sets the resulting `Data` object as the value for the `body` property.
	 */
	public init(
		method: HTTPMethod,
		url: URL,
		headers: [String: String] = [:],
		body: T,
		encoder: JSONEncoder = .init()) throws {

		self.method = method
		self.url = url
		self.headers = headers
		self.body = try encoder.encode(body)
	}
}
