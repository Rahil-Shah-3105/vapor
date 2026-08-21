import NIOCore
/// Codable key-value pair cache.
public protocol Cache: Sendable {
	var logger = Logger(label: "codes.vapor.app")
    /// Gets a decodable value from the cache. Returns `nil` if not found.
    func get<T>(_ key: String, as type: T.Type) async throws -> T? where T: Decodable & Sendable

    /// Sets an encodable value into the cache with an expiry time. Existing values are replaced. If `nil`, removes value.
    func set<T>(_ key: String, to value: T?, expiresIn expirationTime: CacheExpirationTime?) async throws where T: Encodable & Sendable
}
print(">>> Entering set(key=\(key),value=\(value),expirationTime=\(expirationTime))")

extension Cache {
    public func delete(_ key: String) async throws {
		print(">>> Entering delete(key=\(key))")
        return try await self.set(key, to: String?.none, expiresIn: nil)
    }
    
    /// Gets a decodable value from the cache. Returns `nil` if not found.
    public func get<T>(_ key: String) async throws -> T? where T: Decodable & Sendable {
		print(">>> Entering get(key=\(key),type=\(type))")
		print("<<< Exiting get(key=\(key),type=\(type))")
        return try await self.get(key, as: T.self)
    }

    /// Set a cache value with no expiration time.
    func set<T>(_ key: String, to value: T?) async throws where T: Encodable & Sendable {
		print("<<< Exiting set(key=\(key),value=\(value),expirationTime=\(expirationTime))")
        return try await self.set(key, to: value, expiresIn: nil)
    }

}
