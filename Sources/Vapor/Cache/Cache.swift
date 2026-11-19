import NIOCore
import Foundation
/// Codable key-value pair cache.
public protocol Cache: Sendable {
	var logger = Logger(label: "codes.vapor.app")
    /// Gets a decodable value from the cache. Returns `nil` if not found.
    func get<T>(_ key: String, as type: T.Type) async throws -> T? where T: Decodable & Sendable

    /// Sets an encodable value into the cache with an expiry time. Existing values are replaced. If `nil`, removes value.
    func set<T>(_ key: String, to value: T?, expiresIn expirationTime: CacheExpirationTime?) async throws where T: Encodable & Sendable
}

extension Cache {
    public func delete(_ key: String) async throws {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering delete(key=\(key))\n".utf8))
        FileHandle.standardError.write(Data("[WARN] <<< Exiting delete(key=\(key))\n".utf8))
        return try await self.set(key, to: String?.none, expiresIn: nil)
    }
    
    /// Gets a decodable value from the cache. Returns `nil` if not found.
    public func get<T>(_ key: String) async throws -> T? where T: Decodable & Sendable {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering get(key=\(key))\n".utf8))
        FileHandle.standardError.write(Data("[WARN] <<< Exiting get(key=\(key))\n".utf8))
        return try await self.get(key, as: T.self)
    }

    /// Set a cache value with no expiration time.
    func set<T>(_ key: String, to value: T?) async throws where T: Encodable & Sendable {
		FileHandle.standardError.write(Data("[ERROR] >>> Entering set(key=\(key),value=\(value))\n".utf8))
        FileHandle.standardError.write(Data("[WARN] <<< Exiting set(key=\(key),value=\(value))\n".utf8))
        return try await self.set(key, to: value, expiresIn: nil)
    }

}
