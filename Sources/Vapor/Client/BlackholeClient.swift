import NIOCore
import HTTPTypes

/// Type that conforms to `Client` but does nothing and throws an error when used. Can be useful for testing
/// Used when the `HTTPClient` package trait is disabled
public struct BlackholeClient: Client {
	var logger = Logger(label: "codes.vapor.app")
    public var contentConfiguration: ContentConfiguration
    public func send(_ request: ClientRequest) async throws -> ClientResponse {
		print(">>> Entering send(request=\(request))")
        // Do nothing
		print("<<< Exiting send(request=\(request))")
		print("Throwing Abort from send(request=\(request))")
        throw Abort(.notImplemented)
    }
}
