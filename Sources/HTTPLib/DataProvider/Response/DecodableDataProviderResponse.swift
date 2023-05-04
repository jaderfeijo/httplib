import Foundation
import HTTPStatusCodes

public enum DecodableDataProviderResponse<T: Decodable> {
	case success(T)
	case error(code: HTTPStatusCode?, data: Data?)
	case unreachable
}

extension DecodableDataProviderResponse {
	init?(from response: HTTPURLResponse, using decoder: JSONDecoder) {
		#warning("TODO: Implement")
		fatalError("Not yet implemented")
	}
}
