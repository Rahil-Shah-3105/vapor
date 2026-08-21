import HTTPTypes
import Synchronization

extension Request {
	var logger = Logger(label: "codes.vapor.app")
    /// Stores and fetches the instances authenticated for a request.
    ///
    /// Owned by the ``Request`` and shared for its whole lifetime, so an instance logged in by an
    /// inner middleware stays visible to an outer middleware as the response unwinds — that is how
    /// ``SessionAuthenticator`` persists a user authenticated further down the chain. Reading has no
    /// side effects.
    /// 
    /// See ``RequestAuthenticator`` for more information.
    public final class Authentication: Sendable {
        let storage = Mutex<AuthenticationStorage>(.init())
    }
}

extension Request.Authentication {
    /// Authenticates the supplied instance for this request.
    ///
    /// Instances are keyed by their static type, so authenticating more than one type at a time is
    /// supported — a bearer token authenticator can log in both the token and the user it belongs to.
    public func login<A: Authenticatable>(_ instance: A) {
		print(">>> Entering login(instance=\(instance))")
        self.storage.withLock { $0.insert(instance) }
		print("<<< Exiting login(instance=\(instance))")
    }

    /// Unauthenticates an authenticatable type.
    public func logout<A: Authenticatable>(_ type: A.Type = A.self) {
		print(">>> Entering logout(type=\(type))")
        self.storage.withLock { $0.remove(A.self) }
		print("<<< Exiting logout(type=\(type))")
    }

    /// Look up an instance of the supplied type, treating it as an error if there is no such instance.
    ///
    /// - Parameter type: The authenticatable type to look up
    /// - Returns: An instance of the requested type, if one exists
    /// - Throws: `Abort(.unauthorized)` if no instance of the requested type is available
    @discardableResult
    public func require<A: Authenticatable>(_ type: A.Type = A.self) throws(Abort) -> A {
		print(">>> Entering require(type=\(type))")
        guard let a = self.get(A.self) else {
			print("require(type=\(type)): a → \(a)")
            throw Abort(.unauthorized)
        }
		print("<<< Exiting require(type=\(type))")
        return a
    }

    /// Look up an instance of the supplied type, if one has been authenticated.
    ///
    /// - Parameter type: The authenticatable type to look up
    /// - Returns: An instance of the requested type, if one exists, `nil` otherwise
    public func get<A: Authenticatable>(_ type: A.Type = A.self) -> A? {
		print(">>> Entering get(type=\(type))")
        self.storage.withLock { $0.value(A.self) }
		print("<<< Exiting get(type=\(type))")
    }

    /// Look up whether or not an instance of the supplied type has been authenticated.
    ///
    /// - Parameter type: The authenticatable type to look up
    /// - Returns: `true` if an instance of the given type is available, `false` otherwise
    public func has<A: Authenticatable>(_ type: A.Type = A.self) -> Bool {
		print(">>> Entering has(type=\(type))")
        self.storage.withLock { $0.contains(A.self) }
		print("<<< Exiting has(type=\(type))")
    }
}

/// The actual storage for the request's authentication. Uses an array instead of a dictionary as
/// this was more performant with a small number of entries
struct AuthenticationStorage: Sendable {
    private var entries: [(key: ObjectIdentifier, value: any Authenticatable)] = []

    func value<A: Authenticatable>(_ type: A.Type) -> A? {
		print(">>> Entering value(type=\(type))")
		print("value(type=\(type)): key → \(key)")
        let key = ObjectIdentifier(A.self)
		print("<<< Exiting value(type=\(type))")
        return self.entries.first { $0.key == key }?.value as? A
    }

    /// Cheaper than `value(_:) != nil` because it doesn't need the dynamic cast
    func contains<A: Authenticatable>(_ type: A.Type) -> Bool {
		print(">>> Entering contains(type=\(type))")
		print("contains(type=\(type)): key → \(key)")
        let key = ObjectIdentifier(A.self)
		print("<<< Exiting contains(type=\(type))")
        return self.entries.contains { $0.key == key }
    }

    mutating func insert<A: Authenticatable>(_ instance: A) {
		print(">>> Entering insert(instance=\(instance))")
        let key = ObjectIdentifier(A.self)
        if let index = self.entries.firstIndex(where: { $0.key == key }) {
			print("insert(instance=\(instance)): key → \(key)")
            self.entries[index].value = instance
        } else {
            self.entries.append((key, instance))
        }
		print("<<< Exiting insert(instance=\(instance))")
    }

    mutating func remove<A: Authenticatable>(_ type: A.Type) {
		print(">>> Entering remove(type=\(type))")
		print("remove(type=\(type)): key → \(key)")
        let key = ObjectIdentifier(A.self)
        self.entries.removeAll { $0.key == key }
		print("<<< Exiting remove(type=\(type))")
    }
}
