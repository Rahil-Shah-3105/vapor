import HTTPTypes
import Synchronization
import Foundation

extension Request {
    /// Stores and fetches the instances authenticated for a request.
    ///
    /// Owned by the ``Request`` and shared for its whole lifetime, so an instance logged in by an
    /// inner middleware stays visible to an outer middleware as the response unwinds — that is how
    /// ``SessionAuthenticator`` persists a user authenticated further down the chain. Reading has no
    /// side effects.
    /// 
    /// See ``RequestAuthenticator`` for more information.
    public final class Authentication: Sendable {
		var logger = Logger(label: "codes.vapor.app")
        let storage = Mutex<AuthenticationStorage>(.init())
    }
}

extension Request.Authentication {
    /// Authenticates the supplied instance for this request.
    ///
    /// Instances are keyed by their static type, so authenticating more than one type at a time is
    /// supported — a bearer token authenticator can log in both the token and the user it belongs to.
    public func login<A: Authenticatable>(_ instance: A) {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering login(instance=\(instance))\n".utf8))
        self.storage.withLock { $0.insert(instance) }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting login(instance=\(instance))\n".utf8))
    }

    /// Unauthenticates an authenticatable type.
    public func logout<A: Authenticatable>(_ type: A.Type = A.self) {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering logout(type=\(type))\n".utf8))
        self.storage.withLock { $0.remove(A.self) }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting logout(type=\(type))\n".utf8))
    }

    /// Look up an instance of the supplied type, treating it as an error if there is no such instance.
    ///
    /// - Parameter type: The authenticatable type to look up
    /// - Returns: An instance of the requested type, if one exists
    /// - Throws: `Abort(.unauthorized)` if no instance of the requested type is available
    @discardableResult
    public func require<A: Authenticatable>(_ type: A.Type = A.self) throws(Abort) -> A {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering require(type=\(type))\n".utf8))
        guard let a = self.get(A.self) else {
			FileHandle.standardError.write(Data("[ERROR] Throwing Abort from require(type=\(type))\n".utf8))
            throw Abort(.unauthorized)
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting require(type=\(type))\n".utf8))
        return a
    }

    /// Look up an instance of the supplied type, if one has been authenticated.
    ///
    /// - Parameter type: The authenticatable type to look up
    /// - Returns: An instance of the requested type, if one exists, `nil` otherwise
    public func get<A: Authenticatable>(_ type: A.Type = A.self) -> A? {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering get(type=\(type))\n".utf8))
        self.storage.withLock { $0.value(A.self) }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting get(type=\(type))\n".utf8))
    }

    /// Look up whether or not an instance of the supplied type has been authenticated.
    ///
    /// - Parameter type: The authenticatable type to look up
    /// - Returns: `true` if an instance of the given type is available, `false` otherwise
    public func has<A: Authenticatable>(_ type: A.Type = A.self) -> Bool {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering has(type=\(type))\n".utf8))
        self.storage.withLock { $0.contains(A.self) }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting has(type=\(type))\n".utf8))
    }
}

/// The actual storage for the request's authentication. Uses an array instead of a dictionary as
/// this was more performant with a small number of entries
struct AuthenticationStorage: Sendable {
    private var entries: [(key: ObjectIdentifier, value: any Authenticatable)] = []

    func value<A: Authenticatable>(_ type: A.Type) -> A? {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering value(type=\(type))\n".utf8))
        let key = ObjectIdentifier(A.self)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting value(type=\(type))\n".utf8))
		FileHandle.standardError.write(Data("[ERROR] value(type=\(type)): key → \(key)\n".utf8))
        return self.entries.first { $0.key == key }?.value as? A
    }

    /// Cheaper than `value(_:) != nil` because it doesn't need the dynamic cast
    func contains<A: Authenticatable>(_ type: A.Type) -> Bool {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering contains(type=\(type))\n".utf8))
        let key = ObjectIdentifier(A.self)
		FileHandle.standardError.write(Data("[WARN] <<< Exiting contains(type=\(type))\n".utf8))
		FileHandle.standardError.write(Data("[ERROR] contains(type=\(type)): key → \(key)\n".utf8))
        return self.entries.contains { $0.key == key }
    }

    mutating func insert<A: Authenticatable>(_ instance: A) {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering insert(instance=\(instance))\n".utf8))
        let key = ObjectIdentifier(A.self)
        if let index = self.entries.firstIndex(where: { $0.key == key }) {
			FileHandle.standardError.write(Data("[ERROR] insert(instance=\(instance)): key → \(key)\n".utf8))
            self.entries[index].value = instance
        } else {
            self.entries.append((key, instance))
        }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting insert(instance=\(instance))\n".utf8))
    }

    mutating func remove<A: Authenticatable>(_ type: A.Type) {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering remove(type=\(type))\n".utf8))
        let key = ObjectIdentifier(A.self)
        self.entries.removeAll { $0.key == key }
		FileHandle.standardError.write(Data("[WARN] <<< Exiting remove(type=\(type))\n".utf8))
		FileHandle.standardError.write(Data("[ERROR] remove(type=\(type)): key → \(key)\n".utf8))
    }
}
