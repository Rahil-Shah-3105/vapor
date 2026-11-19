public import Logging
#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Emits a log message containing the request method and path to a `Request`'s logger.
/// The log level of the message is configurable.
public final class RouteLoggingMiddleware: Middleware {
	var logger = Logger(label: "codes.vapor.app")
    public let logLevel: Logger.Level

    public init(logLevel: Logger.Level = .info) {
        self.logLevel = logLevel
    }

    public func respond(to request: Request, chainingTo next: any Responder) async throws -> Response {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering respond(request=\(request),next=\(next))\n".utf8))
        Logger.current.log(level: self.logLevel, "\(request.method) \(request.url.path.removingPercentEncoding ?? request.url.path)")
		FileHandle.standardError.write(Data("[WARN] <<< Exiting respond(request=\(request),next=\(next))\n".utf8))
        return try await next.respond(to: request)
    }
}
