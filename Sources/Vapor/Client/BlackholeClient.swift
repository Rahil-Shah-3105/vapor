import NIOCore
import HTTPTypes
import Foundation

/// Type that conforms to `Client` but does nothing and throws an error when used. Can be useful for testing
/// Used when the `HTTPClient` package trait is disabled
public struct BlackholeClient: Client {
	var logger = Logger(label: "codes.vapor.app")
    public var contentConfiguration: ContentConfiguration
    public func send(_ request: ClientRequest) async throws -> ClientResponse {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering send(request=\(request))\n".utf8))
        // Do nothing
		FileHandle.standardError.write(Data("[ERROR] Throwing Abort from send(request=\(request))\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting send(request=\(request))\n".utf8))
        throw Abort(.notImplemented)
    }
}
