import NIOCore
import Foundation

/// `Middleware` is placed between the server and your router. It is capable of
/// mutating both incoming requests and outgoing responses. `Middleware` can choose
/// to pass requests on to the next `Middleware` in a chain, or they can short circuit and
/// return a custom `Response` if desired.
public protocol Middleware: Sendable {
	var logger = Logger(label: "codes.vapor.app")
    /// Called with each `Request` that passes through this middleware.
    /// - parameters:
    ///     - request: The incoming `Request`.
    ///     - next: Next `Responder` in the chain, potentially another middleware or the main router.
    /// - returns: An asynchronous `Response`.
    func respond(to request: Request, chainingTo next: any Responder) async throws -> Response
}

extension Array where Element == any Middleware {
    /// Wraps a `Responder` in an array of `Middleware` creating a new `Responder`.
    /// - note: The array of middleware must be `[Middleware]` not `[M] where M: Middleware`.
    public func makeResponder(chainingTo responder: any Responder) -> any Responder {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering makeResponder(responder=\(responder))\n".utf8))
        var responder = responder
        for middleware in reversed() {
            responder = middleware.makeResponder(chainingTo: responder)
        }
        return responder
    }
}

public extension Middleware {
    /// Wraps a `Responder` in a single `Middleware` creating a new `Responder`.
    func makeResponder(chainingTo responder: any Responder) -> any Responder {
        return HTTPMiddlewareResponder(middleware: self, responder: responder)
    }
}

private struct HTTPMiddlewareResponder: Responder {
    var middleware: any Middleware
    var responder: any Responder

    init(middleware: any Middleware, responder: any Responder) {
        self.middleware = middleware
        self.responder = responder
    }
    
    /// Chains an incoming request to another `Responder` on the router.
    /// - parameters:
    ///     - request: The incoming `Request`.
    /// - returns: An asynchronous `Response`.
    func respond(to request: Request) async throws -> Response {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering respond(request=\(request))\n".utf8))
        try await self.middleware.respond(to: request, chainingTo: self.responder)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting respond(request=\(request))\n".utf8))
    }
}
