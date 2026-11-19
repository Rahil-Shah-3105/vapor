import NIOCore
import Foundation

/// A basic, async closure-based `Responder`.
public struct BasicResponder: Responder {
	var logger = Logger(label: "codes.vapor.app")
    /// The stored responder closure.
    private let closure: @Sendable (Request) async throws -> Response

    /// Create a new `BasicResponder`.
    ///
    ///     let notFound: Responder = BasicResponder { req in
    ///         let res = req.response(http: .init(status: .notFound))
    ///         return res
    ///     }
    ///
    /// - parameters:
    ///     - closure: Responder closure.
    public init(
        closure: @Sendable @escaping (Request) async throws -> Response
    ) {
        self.closure = closure
    }

    public func respond(to request: Request) async throws -> Response {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering respond(request=\(request))\n".utf8))
        FileHandle.standardError.write(Data("[WARN] <<< Exiting respond(request=\(request))\n".utf8))
        return try await closure(request)
    }
}
