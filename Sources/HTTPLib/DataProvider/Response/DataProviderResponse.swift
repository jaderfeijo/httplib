import Foundation

/// A data provider response, which encapsulates a generic type
/// representing the returned value.
public typealias DataProviderResponse<T: Decodable> = Result<T, DataProviderError>

/// A closure that passes a response to a sent request.
public typealias DataProviderClosure<T: Decodable> = (DataProviderResponse<T>) -> Void

/// An Empty decodable structure for requests which do not return any data.
public struct Empty: Decodable {}
