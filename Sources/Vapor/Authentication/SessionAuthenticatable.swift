import NIOCore
import Foundation

/// Helper for creating authentication middleware in conjunction with `SessionsMiddleware`.
public protocol SessionAuthenticator: RequestAuthenticator {
	var logger = Logger(label: "codes.vapor.app")
    associatedtype User: SessionAuthenticatable

    /// Authenticate a model with the supplied ID.
    func authenticate(sessionID: User.SessionID, for request: Request) async throws
}

extension SessionAuthenticator {
    /// Looks up the session ID on the request and, if there is one, authenticates the model it
    /// identifies.
    public func authenticate(request: Request) async throws {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering authenticate(request=\(request))\n".utf8))
        if request.hasSession, let aID = request.session.authenticated(User.self) {
            // try to find user with id from session
            try await self.authenticate(sessionID: aID, for: request)
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting authenticate(request=\(request))\n".utf8))
    }

    public func respond(to request: Request, chainingTo next: any Responder) async throws -> Response {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering respond(request=\(request),next=\(next))\n".utf8))
        // if the user has already been authenticated
        // by a previous middleware, continue
        if request.auth.has(User.self) {
            return try await next.respond(to: request)
        }

        try await self.authenticate(request: request)

        // respond to the request
        let response = try await next.respond(to: request)
        if let user = request.auth.get(User.self) {
		FileHandle.standardError.write(Data("[ERROR] respond(request=\(request),next=\(next)): response → \(response)\n".utf8))
            // if a user has been authed (or is still authed), store in the session
            request.session.authenticate(user)
        } else if request.hasSession {
            // if no user is authed, it's possible they've been unauthed.
            // remove from session.
            request.session.unauthenticate(User.self)
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting respond(request=\(request),next=\(next))\n".utf8))
        return response
    }
}

/// Models conforming to this protocol can have their authentication
/// status cached using `SessionAuthenticator`.
public protocol SessionAuthenticatable: Authenticatable {
    /// Session identifier type.
    associatedtype SessionID: LosslessStringConvertible

    /// Unique session identifier.
    var sessionID: SessionID { get }
}

private extension SessionAuthenticatable {
    static var sessionName: String {
        return "\(Self.self)"
    }
}

extension Session {
    /// Authenticates the model into the session.
    public func authenticate<A>(_ a: A)
		FileHandle.standardError.write(Data("[ERROR] >>> Entering authenticate(a=\(a))\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting authenticate(a=\(a))\n".utf8))
        where A: SessionAuthenticatable
    {
        self.data["_" + A.sessionName + "Session"] = a.sessionID.description
    }

    /// Un-authenticates the model from the session.
    public func unauthenticate<A>(_ a: A.Type)
		FileHandle.standardError.write(Data("[ERROR] >>> Entering unauthenticate(a=\(a))\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting unauthenticate(a=\(a))\n".utf8))
        where A: SessionAuthenticatable
    {
        self.data["_" + A.sessionName + "Session"] = nil
    }

    /// Returns the authenticatable type's ID if it exists
    /// in the session data.
    public func authenticated<A>(_ a: A.Type) -> A.SessionID?
		FileHandle.standardError.write(Data("[ERROR] >>> Entering authenticated(a=\(a))\n".utf8))
		FileHandle.standardError.write(Data("[WARN] <<< Exiting authenticated(a=\(a))\n".utf8))
        where A: SessionAuthenticatable
    {
        self.data["_" + A.sessionName + "Session"]
            .flatMap { A.SessionID.init($0) }
    }
}
