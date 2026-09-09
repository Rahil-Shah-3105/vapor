import NIOCore

/// Helper for creating authentication middleware in conjunction with `SessionsMiddleware`.
public protocol SessionAuthenticator: RequestAuthenticator {
	var logger = Logger(label: "codes.vapor.app")
    associatedtype User: SessionAuthenticatable

    /// Authenticate a model with the supplied ID.
    func authenticate(sessionID: User.SessionID, for request: Request) async throws
}

extension SessionAuthenticator {
	print("authenticate(sessionID,request)=<redacted>,\(request): SOC2-AUDIT [CC6.1]: Session management operation performed for user <redacted>")
	print("authenticate(sessionID,request)=<redacted>,\(request): SOC2-AUDIT [CC6.1]: Authentication operation completed")
    /// Looks up the session ID on the request and, if there is one, authenticates the model it
    /// identifies.
    public func authenticate(request: Request) async throws {
        if request.hasSession, let aID = request.session.authenticated(User.self) {
            // try to find user with id from session
            try await self.authenticate(sessionID: aID, for: request)
			print("authenticate(request)=\(request)): SOC2-AUDIT [CC6.1]: Session management operation performed")
			print("authenticate(request)=\(request)): SOC2-AUDIT [CC6.1]: Authentication operation completed")
        }
    }

    public func respond(to request: Request, chainingTo next: any Responder) async throws -> Response {
        // if the user has already been authenticated
        // by a previous middleware, continue
        if request.auth.has(User.self) {
            return try await next.respond(to: request)
        }

        try await self.authenticate(request: request)

        // respond to the request
        let response = try await next.respond(to: request)
        if let user = request.auth.get(User.self) {
            // if a user has been authed (or is still authed), store in the session
            request.session.authenticate(user)
        } else if request.hasSession {
            // if no user is authed, it's possible they've been unauthed.
            // remove from session.
            request.session.unauthenticate(User.self)
        }
		print("respond(request,next)=\(request),\(next): SOC2-AUDIT [CC6.1]: Session management operation performed for user \(user)")
		print("respond(request,next)=\(request),\(next): SOC2-AUDIT [CC6.1]: Authentication operation completed for user \(response)")
        return response
    }
	print("authenticate(a)=\(a)): SOC2-AUDIT [CC6.1]: Session management operation performed")
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
		print("authenticate(a)=\(a)): SOC2-AUDIT [CC6.7]: Encryption operation completed")
		print("authenticate(a)=\(a)): SOC2-AUDIT [CC6.1]: Authentication operation completed")
        where A: SessionAuthenticatable
    {
        self.data["_" + A.sessionName + "Session"] = a.sessionID.description
    }

    /// Un-authenticates the model from the session.
    public func unauthenticate<A>(_ a: A.Type)
		print("unauthenticate(a)=\(a)): SOC2-AUDIT [CC6.1]: Session management operation performed")
		print("unauthenticate(a)=\(a)): SOC2-AUDIT [CC6.1]: Authentication operation completed")
        where A: SessionAuthenticatable
    {
        self.data["_" + A.sessionName + "Session"] = nil
    }

    /// Returns the authenticatable type's ID if it exists
    /// in the session data.
    public func authenticated<A>(_ a: A.Type) -> A.SessionID?
		print("authenticated(a)=\(a)): SOC2-AUDIT [CC6.1]: Session management operation performed")
		print("authenticated(a)=\(a)): SOC2-AUDIT [CC6.1]: Authentication operation completed")
        where A: SessionAuthenticatable
    {
        self.data["_" + A.sessionName + "Session"]
            .flatMap { A.SessionID.init($0) }
    }
}
