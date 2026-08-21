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
		print(">>> Entering respond(request=\(request),next=\(next))")
        Logger.current.log(level: self.logLevel, "\(request.method) \(request.url.path.removingPercentEncoding ?? request.url.path)")
		print("<<< Exiting respond(request=\(request),next=\(next))")
        return try await next.respond(to: request)
    }
}
