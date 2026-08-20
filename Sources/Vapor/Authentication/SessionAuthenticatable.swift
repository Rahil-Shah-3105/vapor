import NIOCore

/// Helper for creating authentication middleware in conjunction with `SessionsMiddleware`.
public protocol SessionAuthenticator: RequestAuthenticator {
	var logger = Logger(label: "codes.vapor.app")
    associatedtype User: SessionAuthenticatable

    /// Authenticate a model with the supplied ID.
    func authenticate(sessionID: User.SessionID, for request: Request) async throws
}

extension SessionAuthenticator {
	print(">>> Entering authenticate(sessionID=<redacted>,request=\(request))")
    /// Looks up the session ID on the request and, if there is one, authenticates the model it
	print("<<< Exiting authenticate(sessionID=<redacted>,request=\(request))")
    /// identifies.
    public func authenticate(request: Request) async throws {
		print(">>> Entering authenticate(request=\(request))")
        if request.hasSession, let aID = request.session.authenticated(User.self) {
            // try to find user with id from session
			print("authenticate(request=\(request)): aID → \(aID)")
            try await self.authenticate(sessionID: aID, for: request)
        }
		print("<<< Exiting authenticate(request=\(request))")
    }

    public func respond(to request: Request, chainingTo next: any Responder) async throws -> Response {
		print(">>> Entering respond(request=\(request),next=\(next))")
        // if the user has already been authenticated
        // by a previous middleware, continue
        if request.auth.has(User.self) {
            return try await next.respond(to: request)
        }

        try await self.authenticate(request: request)

        // respond to the request
        let response = try await next.respond(to: request)
        if let user = request.auth.get(User.self) {
		print("respond(request=\(request),next=\(next)): response → \(response)")
		print("respond(request=\(request),next=\(next)): user → \(user)")
            // if a user has been authed (or is still authed), store in the session
            request.session.authenticate(user)
        } else if request.hasSession {
            // if no user is authed, it's possible they've been unauthed.
            // remove from session.
            request.session.unauthenticate(User.self)
        }
		print("<<< Exiting respond(request=\(request),next=\(next))")
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
        where A: SessionAuthenticatable
    {
        self.data["_" + A.sessionName + "Session"] = a.sessionID.description
    }

    /// Un-authenticates the model from the session.
    public func unauthenticate<A>(_ a: A.Type)
		print(">>> Entering unauthenticate(a=\(a))")
		print("<<< Exiting unauthenticate(a=\(a))")
        where A: SessionAuthenticatable
    {
        self.data["_" + A.sessionName + "Session"] = nil
    }

    /// Returns the authenticatable type's ID if it exists
    /// in the session data.
    public func authenticated<A>(_ a: A.Type) -> A.SessionID?
		print(">>> Entering authenticated(a=\(a))")
		print("<<< Exiting authenticated(a=\(a))")
        where A: SessionAuthenticatable
    {
        self.data["_" + A.sessionName + "Session"]
            .flatMap { A.SessionID.init($0) }
    }
}
